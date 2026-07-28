# span-fields.awk — zieht die Span-Felder aus einer Hook-Payload (JSON auf stdin).
# POSIX-awk (busybox/gawk/BSD), kein gawk-Spezifikum — dieselbe Bauart wie
# extract-command.awk (ADR-0004: zero-dep bash+awk), aber ein eigener Scanner:
# der Guard ist fail-CLOSED und darf im Zweifel blocken, die Telemetrie ist
# fail-OPEN und darf im Zweifel nur sich selbst verlieren (ADR-0011 Festlegung 6).
#
# Ausgabe: je Zeile `schluessel<TAB>json-escapter-wert` — OHNE umschliessende
# Anfuehrungszeichen (die setzt der Aufrufer, je nachdem ob das Feld als String
# oder als Zahl in die Span-Zeile geht). Der Wert ist bereits escapt, damit er
# weder Zeilenumbruch noch Tab in die Transfer-Zeile bringt und vom Aufrufer
# unveraendert uebernommen werden kann.
# Nicht gefundene Felder erscheinen NICHT — der Aufrufer entscheidet, was fehlt.
#
# GESCHLOSSENES SCHEMA (ADR-0011 Festlegung 1.3): hier steht die vollstaendige
# Liste dessen, was ueberhaupt aus der Payload gelesen wird. Ein neues Feld in
# einer kuenftigen Payload wird NICHT still mitgeschrieben — es muesste hier
# eingetragen werden, und das ist eine Entscheidung, kein Nebeneffekt.
#
# ARGUMENT-WERTE werden NIE roh uebernommen (ADR-0011 Festlegung 2). Der Scanner
# liefert aus `tool_input` genau zwei abgeleitete Groessen: den Pfad (das
# Audit-Datum) und das erste Token der Kommandozeile (das Programm) samt
# Argument-Anzahl. Der Kommando-REST und jeder Datei-Inhalt verlassen diesen
# Scanner nicht.

function esc(s,   i, n, c, out, code) {
  n = length(s); out = ""
  for (i = 1; i <= n; i++) {
    c = substr(s, i, 1)
    if (c == "\\")      out = out "\\\\"
    else if (c == "\"") out = out "\\\""
    else if (c == "\n") out = out "\\n"
    else if (c == "\t") out = out "\\t"
    else if (c == "\r") out = out "\\r"
    else {
      code = ctrl[c]
      if (code != "") out = out sprintf("\\u%04x", code)
      else out = out c
    }
  }
  return out
}

# emit gibt ein Feld aus — einmal je Schluessel (der erste Treffer gewinnt,
# damit ein spaeteres gleichnamiges Feld in einem fremden Teilobjekt nicht
# ueberschreibt).
function emit(key, val) {
  if (seen[key] == 1) return
  seen[key] = 1
  printf "%s\t%s\n", key, esc(val)
}

BEGIN { for (k = 1; k < 32; k++) ctrl[sprintf("%c", k)] = k }

{ doc = (NR == 1) ? $0 : doc "\n" $0 }

END {
  n = length(doc)
  depth = 0; instr = 0; esc_on = 0; buf = ""

  for (i = 1; i <= n; i++) {
    c = substr(doc, i, 1)

    if (instr) {
      if (esc_on) {
        esc_on = 0
        if (c == "\"") buf = buf "\""
        else if (c == "\\") buf = buf "\\"
        else if (c == "/") buf = buf "/"
        else if (c == "n") buf = buf "\n"
        else if (c == "t") buf = buf "\t"
        else if (c == "r") buf = buf "\r"
        else if (c == "b") buf = buf sprintf("%c", 8)
        else if (c == "f") buf = buf sprintf("%c", 12)
        else if (c == "u") {
          # \uXXXX: der Wert bleibt undekodiert (ein Ersatzzeichen genuegt fuers
          # Audit), aber der Scanner muss die vier Hex-Stellen ueberspringen —
          # sonst desynchronisiert er ueber das schliessende " hinaus.
          if (substr(doc, i + 1, 4) ~ /^[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]$/) {
            buf = buf "?"; i = i + 4
          }
        }
        else buf = buf c
        continue
      }
      if (c == "\\") { esc_on = 1; continue }
      if (c == "\"") {
        if (depth > 0 && ctype[depth] == "o" && wantkey[depth] == 1) {
          curkey[depth] = buf
        } else if (depth == 1 && ctype[1] == "o") {
          k1 = curkey[1]
          if (k1 == "hook_event_name" || k1 == "tool_name" || k1 == "tool_use_id" ||
              k1 == "session_id" || k1 == "agent_id" || k1 == "agent_type" ||
              k1 == "transcript_path" || k1 == "permission_mode")
          {
            emit(k1, buf)
            if (k1 == "tool_name") toolname = buf   # entscheidet unten die Erfassung
          }
          else if (k1 == "error") emit("error", "1")
        } else if (depth == 2 && ctype[2] == "o" && curkey[1] == "tool_input") {
          # NICHT sofort ausgeben: ob diese Werte ueberhaupt erfasst werden
          # duerfen, entscheidet der WERKZEUG-NAME — und der kann in der Payload
          # nach `tool_input` stehen. Also merken und am Ende entscheiden.
          k2 = curkey[2]
          if (k2 == "file_path" || k2 == "notebook_path") { if (cand_path == "") cand_path = buf }
          else if (k2 == "command") { if (cand_cmd == "") cand_cmd = buf }
        }
        instr = 0
        continue
      }
      buf = buf c
      continue
    }

    if (c == "\"") { instr = 1; buf = ""; continue }
    if (c == "{") { depth++; ctype[depth] = "o"; wantkey[depth] = 1; curkey[depth] = ""; continue }
    if (c == "}") { if (depth > 0) depth--; continue }
    if (c == "[") { depth++; ctype[depth] = "a"; continue }
    if (c == "]") { if (depth > 0) depth--; continue }
    if (c == ":") { if (depth > 0 && ctype[depth] == "o") wantkey[depth] = 0; continue }
    if (c == ",") { if (depth > 0 && ctype[depth] == "o") wantkey[depth] = 1; continue }
  }
  # --- Der fail-closed Default haengt am WERKZEUG-NAMEN -----------------------
  # ADR-0011 Festlegung 2: die Tabelle bildet auf konkrete Namen ab; was nicht
  # namentlich gelistet ist, gibt NUR Name und Status preis. Die Achse ist der
  # Werkzeug-Name, nicht der Feld-Name — sonst gaebe jedes unbekannte Werkzeug,
  # das zufaellig `command` oder `file_path` fuehrt, seine Argumente preis
  # (Review-Befund HIGH-1: `mcp__db__run` lieferte `"program":"psql"`).
  tn = toolname
  if (tn == "Write" || tn == "Edit" || tn == "MultiEdit" || tn == "NotebookEdit" || tn == "Read") {
    if (cand_path != "") emit("path", cand_path)
  } else if (tn == "Bash" || tn == "BashOutput") {
    if (cand_cmd != "") {
      # Das PROGRAMM ist nicht schlicht das erste Feld: eine Kommandozeile darf
      # mit Zuweisungen beginnen, und deren WERTE sind oft genau das, was nie
      # ins Log darf (Review-Befund HIGH-7: `GITHUB_TOKEN=ghp_… gh pr create`
      # landete verbatim als "program"). Fuehrende NAME=WERT-Praefixe werden
      # deshalb uebersprungen; bleibt danach etwas mit `=` uebrig, wird GAR
      # NICHTS ausgegeben — im Zweifel nichts erfassen.
      m = split(cand_cmd, parts, /[ \t\n]+/)
      prog = ""
      for (p = 1; p <= m; p++) {
        if (parts[p] == "") continue
        if (parts[p] ~ /^[A-Za-z_][A-Za-z0-9_]*=/) continue   # Zuweisungs-Praefix
        prog = parts[p]
        break
      }
      if (prog != "" && prog !~ /=/) {
        emit("program", prog)
        emit("argc", sprintf("%d", (m > 0 ? m - 1 : 0)))
      }
    }
  }
  # Kein Exit-Code-Signal: ein unvollstaendiges JSON kostet Felder, nicht den
  # Lauf (fail-open). Der Aufrufer klemmt ohnehin auf 0.
}
