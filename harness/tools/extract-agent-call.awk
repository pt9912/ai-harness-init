# extract-agent-call.awk — zieht tool_input.subagent_type und
# tool_input.run_in_background aus der PreToolUse-Hook-JSON eines Agent-Aufrufs.
# POSIX-awk (busybox/gawk/BSD), kein gawk-Spezifikum.
#
# Stdout = GENAU zwei Zeilen, feste Reihenfolge:
#   1: run_in_background als Literal ("true"/"false") oder "ABSENT"
#   2: subagent_type oder "ABSENT"
# Exit 0 = ok, Exit 3 = Parse-Zweifel/fail-closed — der Guard verweigert dann.
#
# Geschwister von extract-command.awk und bewusst dieselbe Bauart:
# zeichenweiser Scanner mit Tiefen-/Key-Stack, der JSON-Keys von -Values
# unterscheidet. Das ist hier NICHT Kosmetik: ein Agent-Prompt ist Freitext und
# kann die Zeichenkette "subagent_type" enthalten — ein Regex-Griff (sed/grep)
# wuerde den Treffer IM Prompt nehmen und der Guard entschiede ueber die falsche
# Groesse. Nur der Pfad tool_input -> <key> (Objekt-Tiefe 2) zaehlt.
#
# ZWEI UNTERSCHIEDE zu extract-command.awk:
#  (a) run_in_background ist ein NACKTER Literal (true/false), kein String — der
#      String-Scanner allein sieht es nicht. Dafuer der lit-Puffer unten.
#  (b) subagent_type wird auf [A-Za-z0-9_:-] geprueft, weil der Guard daraus
#      einen PFAD baut (.claude/agents/<name>.md). Alles andere -> exit 3, also
#      verweigern: ein Typname mit Zeilenumbruch, Slash oder Punkt-Punkt ist
#      kein Rollenname, sondern ein Versuch.
#      Grenze, ausgesprochen: ein Typ, der sich nur AEHNLICH schreibt wie eine
#      Rolle (Unicode-Doppelgaenger), faellt hier nicht auf. Der Guard ist ein
#      Stolperdraht, keine Sandbox (ADR-0004) — die zweite Verteidigungslinie
#      ist die Abdeckungszahl in slice-066.

function flushlit() {
  if (lit == "") return
  if (depth >= 2 && ctype[depth] == "o" && curkey[depth] == "run_in_background" &&
      ctype[depth - 1] == "o" && curkey[depth - 1] == "tool_input") {
    ribfound = 1
    ribval = lit
  }
  lit = ""
}

{ doc = (NR == 1) ? $0 : doc "\n" $0 }

END {
  n = length(doc)
  depth = 0       # Verschachtelungstiefe ({}/[])
  instr = 0       # in einem JSON-String?
  esc = 0         # letztes Zeichen war Backslash?
  buf = ""        # aktueller String-Inhalt (dekodiert)
  hadu = 0        # aktueller String enthielt \uXXXX
  lit = ""        # aktueller NACKTER Literal (true/false/Zahl/null)
  sawobj = 0      # je ein Top-Level-Objekt gesehen?
  stfound = 0; stval = ""
  ribfound = 0; ribval = ""

  for (i = 1; i <= n; i++) {
    c = substr(doc, i, 1)

    if (instr) {
      if (esc) {
        esc = 0
        if (c == "\"") buf = buf "\""
        else if (c == "\\") buf = buf "\\"
        else if (c == "/") buf = buf "/"
        else if (c == "n") buf = buf "\n"
        else if (c == "t") buf = buf "\t"
        else if (c == "r") buf = buf "\r"
        else if (c == "b") buf = buf sprintf("%c", 8)
        else if (c == "f") buf = buf sprintf("%c", 12)
        else if (c == "u") {
          # \u verlangt GENAU 4 Hex — sonst desynct ein i+=4 den Scanner ueber
          # ein schliessendes " hinweg und der Guard koennte fail-OPEN gehen.
          if (substr(doc, i + 1, 4) !~ /^[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]$/) exit 3
          hadu = 1; i = i + 4
        }
        else buf = buf c                              # unbekannter Escape: Zeichen behalten
        continue
      }
      if (c == "\\") { esc = 1; continue }
      if (c == "\"") {
        # Stringende: Key oder Value?
        if (depth > 0 && ctype[depth] == "o" && wantkey[depth] == 1) {
          curkey[depth] = buf
        } else if (depth >= 2 && ctype[depth] == "o" && curkey[depth] == "subagent_type" &&
                   ctype[depth - 1] == "o" && curkey[depth - 1] == "tool_input") {
          if (hadu) exit 3
          stfound = 1
          stval = buf
        }
        instr = 0
        continue
      }
      buf = buf c
      continue
    }

    # ausserhalb eines Strings — jeder Strukturwechsel beendet einen Literal
    if (c == "\"") { flushlit(); instr = 1; buf = ""; hadu = 0; continue }
    if (c == "{") { flushlit(); depth++; sawobj = 1; ctype[depth] = "o"; wantkey[depth] = 1; curkey[depth] = ""; continue }
    if (c == "}") { flushlit(); if (depth > 0) depth--; continue }
    if (c == "[") { flushlit(); depth++; ctype[depth] = "a"; continue }
    if (c == "]") { flushlit(); if (depth > 0) depth--; continue }
    if (c == ":") { flushlit(); if (depth > 0 && ctype[depth] == "o") wantkey[depth] = 0; continue }
    if (c == ",") { flushlit(); if (depth > 0 && ctype[depth] == "o") wantkey[depth] = 1; continue }
    if (c == " " || c == "\t" || c == "\n" || c == "\r") { flushlit(); continue }
    lit = lit c
  }

  if (!sawobj) exit 3                      # kein Objekt -> kein/kaputtes JSON -> verweigern
  if (instr == 1 || depth != 0) exit 3     # abgeschnitten/unbalanciert -> verweigern
  # Der Typname wird zum Pfadbestandteil: strenger Zeichensatz, sonst verweigern.
  if (stfound && stval !~ /^[A-Za-z0-9_:-]+$/) exit 3

  printf "%s\n", (ribfound ? ribval : "ABSENT")
  printf "%s\n", (stfound ? stval : "ABSENT")
  exit 0
}
