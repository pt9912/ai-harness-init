# Messung: Trägt ein per `updatedInput` erzwungener Vordergrund die Zähler? (slice-086)

**Datum:** 2026-08-21. **Rolle:** Implementation (Messaufbau, Läufe, Rücknahme).
**Gegenstand:** slice-086 DoD (1) und (2) — kann ein `PreToolUse`-Hook mit
`permissionDecision: "ask"` + `updatedInput` die Vordergrund-Form eines `Agent`-Aufrufs
herstellen, und trägt der `Agent`-Span des so gestarteten Laufs `spawned_role` und die vier
`usage`-Zähler?

**Ergebnis: NEGATIV — der Weg hält nicht.** `updatedInput` wird übernommen — bewiesen am
**statischen** Kontroll-`updatedInput` aus §6, dessen Marker in der Tool-Zeile erschien —, und ein
so übernommenes `updatedInput` mit `"run_in_background": false` erzeugt trotzdem einen
Hintergrund-Start: das Tool kehrt in Millisekunden zurück, und der `Agent`-Span trägt weder
`spawned_role` noch einen der vier Zähler. Der Splice-Lauf (§5) zeigt dasselbe Span-Bild; ob
**seine** gespleißte Ausgabe übernommen wurde, ist nicht beobachtet (der Dialog zeigt die rohe
Eingabe nicht) — wohlgeformt ist sie offline (§4). Das Feld ist im Eingabe-Schema des Werkzeugs
nicht mehr geführt und bleibt in einem nachweislich übernommenen `updatedInput` wirkungslos.

Alle Läufe dieses Dokuments unter `model_version: claude-opus-5[1m]` (aus den Span-Zeilen);
die Messung ist eine Momentaufnahme dieses Datums und dieser Werkzeug-Fassung.

---

## 1. Messaufbau (temporär, uncommittet, vollständig zurückgenommen)

Drei Artefakte, alle nach Abschluss entfernt; `git status` ist leer, die Permission-Lage ist
dieselbe wie vorher:

1. `.claude/hooks/pretooluse-updatedinput-sonde.sh` — die Sonde (Text in §2/§6).
2. `.claude/hooks/sonde-fixture-agent-payload.json` — die Fixture (Text in §3).
3. Ein zweiter Hook-Eintrag im `Agent`-Matcher von `.claude/settings.json`:

```json
{
    "type": "command",
    "command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/pretooluse-updatedinput-sonde.sh"
}
```

## 2. Die Sonde (Splice-Fassung) — verbatim

```bash
#!/usr/bin/env bash
# pretooluse-updatedinput-sonde.sh — temporaerer Messaufbau zu slice-086, uncommittet.
#
# Liest die PreToolUse-Hook-Payload eines Agent-Aufrufs von stdin, uebernimmt den
# Byte-Bereich des tool_input-Objekts UNVERAENDERT (Splice — kein JSON-Encoder,
# der Prompt wird als Bytes durchgereicht und nie interpretiert) und gibt
# permissionDecision "ask" mit updatedInput = tool_input + "run_in_background":false
# zurueck. "ask" zeigt die geaenderte Eingabe vor der Ausfuehrung an — das ist die
# Kontroll-Beobachtung der Messung.
#
# Einziger Ausgang ist stdout. Die Sonde schreibt in KEINE Datei.
# Bei jedem Zweifel (tool_input nicht gefunden, unbalanciert, Scanner desynct):
# KEINE Ausgabe, exit 0 — die normale Permission-Entscheidung laeuft unveraendert.
# Die Sonde ist eine Messung, kein Guard; fail-safe ist hier Schweigen.
#
# Bauart wie harness/tools/extract-agent-call.awk (zeichenweiser Scanner mit
# Tiefen-/Key-Stack): ein Agent-Prompt ist Freitext und kann "tool_input",
# Klammern und Anfuehrungszeichen enthalten — ein Regex-Griff naehme den Treffer
# IM Prompt. Nur der Pfad Top-Level -> tool_input (Objekt-Tiefe 1) zaehlt.
set -euo pipefail

LC_ALL=C awk '
  { doc = (NR == 1) ? $0 : doc "\n" $0 }
  END {
    n = length(doc)
    depth = 0; instr = 0; esc = 0; kb = ""
    s = 0; e = 0
    for (i = 1; i <= n; i++) {
      c = substr(doc, i, 1)
      if (instr) {
        if (esc) {
          esc = 0
          if (c == "u") {
            # \u verlangt GENAU 4 Hex — sonst desynct der Scanner (Vorbild extract-agent-call.awk)
            if (substr(doc, i + 1, 4) !~ /^[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]$/) exit 0
            i = i + 4
          }
          continue
        }
        if (c == "\\") { esc = 1; continue }
        if (c == "\"") {
          instr = 0
          if (depth > 0 && ct[depth] == "o" && wk[depth] == 1) ck[depth] = kb
          continue
        }
        kb = kb c
        continue
      }
      if (c == "\"") { instr = 1; kb = ""; continue }
      if (c == "{") {
        if (depth == 1 && ct[1] == "o" && wk[1] == 0 && ck[1] == "tool_input" && s == 0) s = i
        depth++; ct[depth] = "o"; wk[depth] = 1; ck[depth] = ""
        continue
      }
      if (c == "}") { if (depth > 0) depth--; if (s > 0 && e == 0 && depth == 1) e = i; continue }
      if (c == "[") { depth++; ct[depth] = "a"; continue }
      if (c == "]") { if (depth > 0) depth--; continue }
      if (c == ":") { if (depth > 0 && ct[depth] == "o") wk[depth] = 0; continue }
      if (c == ",") { if (depth > 0 && ct[depth] == "o") wk[depth] = 1; continue }
    }
    if (s == 0 || e <= s || instr != 0 || depth != 0) exit 0
    ti = substr(doc, s, e - s + 1)
    inner = substr(ti, 2, length(ti) - 2)
    tmp = inner; gsub(/[ \t\r\n]/, "", tmp)
    if (tmp == "")
      out = "{\"run_in_background\":false}"
    else
      out = substr(ti, 1, length(ti) - 1) ",\"run_in_background\":false}"
    printf "%s%s%s", \
      "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"ask\",\"permissionDecisionReason\":\"updatedInput-Sonde slice-086: run_in_background:false eingespleisst\",\"updatedInput\":", \
      out, "}}"
    exit 0
  }
'
```

## 3. Die Fixture — verbatim

Eine Zeile; der `prompt` trägt die Markierung und gezielte Fallen (zitiertes `"tool_input"`,
Klammern im Text, nacktes `run_in_background`, Backslash-Escape, Umlaut):

```json
{"session_id":"sonde-fixture","transcript_path":"/tmp/nirgends.jsonl","cwd":"/Development/KI/ai-harness-init","hook_event_name":"PreToolUse","tool_name":"Agent","tool_input":{"description":"Sonden-Fixture slice-086","prompt":"Freitext mit Markierung SONDE-MARKER-7c1de4b2a90f und JSON-Fallen: ein zitiertes \"tool_input\": { hier }, ein nacktes run_in_background im Text, eine Klammer } mitten im Satz, ein Backslash-Escape \\n und ein ü als Escape.","subagent_type":"Explore"}}
```

## 4. Offline-Belege (vor der Verdrahtung)

Prüfskript außerhalb des Repos (Scratchpad), drei Checks, alle grün:

```
CHECK1 Marker durchgereicht: OK
CHECK2 Splice am Ende: OK
CHECK3 Byte-Identitaet: OK (304 Bytes durchgereicht)
```

CHECK3 vergleicht `updatedInput` minus Splice byteweise mit dem `tool_input`-Bereich der
Fixture (bash-Parameter-Expansion, kein Parser).

**Nicht-Aufzeichnung, Gegenbeispiel zuerst (AGENTS.md §3.6).** Suche jeweils:
`grep -rlF 'SONDE-MARKER-7c1de4b2a90f' --exclude-dir=.git --exclude=sonde-fixture-agent-payload.json .`

1. Schreibende Variante (`cat > "$here/sonde-schreibend.log"` statt der awk-Ausgabe) über die
   Fixture gefahren → die Suche **findet** `.claude/hooks/sonde-schreibend.log` (Exit 0, rot
   gesehen). Variante und Log entfernt.
2. Echte Sonde über die Fixture gefahren → dieselbe Suche ist **leer** (Exit 1).
3. Nach der vollständigen Rücknahme (Fixture gelöscht): dieselbe Suche **ohne** die
   Fixture-Ausnahme über das ganze Repo — leer (Exit 1). **Gültig am Messtag, vor diesem
   Dokument** — s. u.

**Ab dem Commit dieses Dokuments wird dieselbe Suche per Konstruktion fündig, und zwar genau in
den Zitaten:** dieses Dokument trägt die Markierung selbst (Fixture in §3, Kommando oben), und ein
Zeitdokument, das es zitiert, ebenso. Der Fall *„die Sonde hat geschrieben"* und der Fall *„ein
Zeitdokument zitiert die Markierung"* sind an der Trefferliste zu trennen: die Sonde schreibt —
wenn sie schreibt — neben sich (`.claude/hooks/`, Punkt 1 oben), ein Zitat steht unter
`docs/reviews/`. Nachgefahren am 2026-08-22 auf `31a7908` (mit dem Review-Report zu diesem Slice im
Baum):

```
$ grep -rlF 'SONDE-MARKER-7c1de4b2a90f' --exclude-dir=.git .
docs/reviews/2026-08-21-updatedinput-messung.md
docs/reviews/2026-08-22-slice-086-review.md              (Exit 0 — zwei Treffer, beide Zitate)
$ grep -rlF 'SONDE-MARKER-7c1de4b2a90f' --exclude-dir=.git . | grep -v 'docs/reviews/'
                                                          (leer, Exit 1)
```

Dasselbe für die Kontroll-Markierung `SONDE-KONTROLLE-9d4b` aus §6: zwei Treffer, dieselben zwei
Dateien; ohne die zitierenden Zeitdokumente leer (Exit 1).

## 5. Die Läufe

**Wo gelesen wird.** Der Span-Bestand liegt unter `.harness/state/spans/` — gitignored,
maschinenlokal, je (Sitzung, Agent) ein Strom (ADR-0011 Festlegung 3); jedes Span-Zitat unten steht mit dem
Kommando, das es liest. Eindeutiger Fundschlüssel einer Zeile ist die `tool_use_id`, nicht die
Sequenznummer — `seq` ist je Strom vergeben und kommt in einer Sitzung mehrfach vor. Tageszählung
über den ganzen Bestand (2026-08-22 gelesen):

```
$ grep -h '"tool":"Agent"' .harness/state/spans/*.jsonl | grep -c '"ts":"2026-08-21'
6
$ grep -h '"tool":"Agent"' .harness/state/spans/*.jsonl | grep '"ts":"2026-08-21' \
    | grep -c -E 'spawned_role|input_tokens'
0
```

Sechs `Agent`-Spans am Messtag, keiner mit Rolle oder Zähler. Dass der Emitter beides schreiben
**kann**, zeigt derselbe Bestand (2026-08-22 gezählt):
`grep -h 'spawned_role' .harness/state/spans/*.jsonl | wc -l` → **89** Zeilen tragen
`spawned_role`, und dieselben 89 tragen alle vier Zähler
(`… | grep input_tokens | grep output_tokens | grep cache_creation_input_tokens | grep -c cache_read_input_tokens`
→ 89); die jüngste stammt vom 2026-08-09 (`… | grep -o '"ts":"[^"]*"' | sort | tail -1`), keine
vom Messtag.

### Lauf 0 — verdrahtete Sitzung, Sonde feuert nicht (Wiederholung statt Deutung)

Verdrahtung mid-session in die laufende Sitzung geschrieben, `Agent`-Aufruf (`Explore`,
Trivial-Auftrag): **kein** Dialog, Tool kehrt sofort zurück. Ursache eingegrenzt statt gedeutet:
dieselbe Sonde liefert offline auf die realistische Payload genau dieses Aufrufs die wohlgeformte
`ask`-Ausgabe (Exit 0) — der fail-safe-Zweig war es nicht. **Die Hook-Liste einer Sitzung wird
beim Session-Start eingefroren; eine mid-session verdrahtete Sonde feuert in derselben Sitzung
nicht.** (Der Hook-*Befehl* wird dagegen bei jedem Feuern frisch von Platte gelesen — §6 nutzt
genau das.) Span des Aufrufs (Hintergrund-Stub) im Haupt-Strom der Sitzung `a2195604…`, per
`tool_use_id` gelesen — `"seq":65` allein wäre nicht eindeutig, es kommt in zwei Strömen dieser
Sitzung vor:

```
$ grep -h '"tool_use_id":"toolu_016F6282frqweYSfy7ZmKNef"' \
    .harness/state/spans/a2195604_396a_4398_8c2e_ac13d666f74b.jsonl
```

```json
{"seq":65,"ts":"2026-08-21T14:43:31Z","event":"PostToolUse","tool":"Agent","tool_use_id":"toolu_016F6282frqweYSfy7ZmKNef","session":"a2195604-396a-4398-8c2e-ac13d666f74b","agent":"","agent_type":"","agent_role":"","slice":["slice-086-vordergrund-per-updatedinput"],"requirement":["LH-QA-01","LH-QA-03"],"adr":["ADR-0011","ADR-0019"],"branch":"main","commit":"3f27b7c7f802","status":"ok","permission_mode":"auto","duration_ms":3,"result_bytes":386,"model_version":"claude-opus-5[1m]"}
```

### Lauf 1 — frische Sitzung, Splice-Sonde (die Messung)

Frische interaktive Sitzung im Repo (Sitzung `d3ef8106…`), Auftrag: einen Explore-Subagenten
starten, der „OK" zurückgibt. Beobachtet (Screenshot-belegt durch den Auftraggeber):

- Der **„ask"-Dialog erschien** und trug die Sonden-Begründung
  („updatedInput-Sonde slice-086: run_in_background:false eingespleisst") — die Hook-Ausgabe war
  wohlgeformt und wurde als Entscheidung angenommen. Der Dialog zeigt die rohe Eingabe nicht an;
  ob `updatedInput` *übernommen* wurde, klärt erst der Kontroll-Lauf (§6).
- Nach der Bestätigung: **„Backgrounded agent"** — die Sitzung wartete per Benachrichtigung, das
  Tool kehrte sofort zurück.

Span, gelesen mit
`grep -h '"tool":"Agent"' .harness/state/spans/d3ef8106_bc2d_4a6e_8bd0_72c91c4b813d.jsonl`
(zwei Zeilen: `seq 1` ist dieser Lauf, `seq 2` der Kontroll-Lauf aus §6; über beide
`grep -c -E 'spawned_role|input_tokens|output_tokens|cache_creation_input_tokens|cache_read_input_tokens'`
→ **0**). Dieser Lauf: `duration_ms: 3`, `result_bytes: 457`, **kein `spawned_role`, keiner der
vier Zähler**:

```json
{"seq":1,"ts":"2026-08-21T18:29:51Z","event":"PostToolUse","tool":"Agent","tool_use_id":"toolu_0181irqRbg1FHcsrfRaBmpA1","session":"d3ef8106-bc2d-4a6e-8bd0-72c91c4b813d","agent":"","agent_type":"","agent_role":"","slice":["slice-086-vordergrund-per-updatedinput"],"requirement":["LH-QA-01","LH-QA-03"],"adr":["ADR-0011","ADR-0019"],"branch":"main","commit":"3f27b7c7f802","status":"ok","permission_mode":"auto","duration_ms":3,"result_bytes":457,"model_version":"claude-opus-5[1m]"}
```

Ein Vorlauf derselben Art in einer weiteren frischen Sitzung (`af347d77…`, 18:26 Uhr) zeigt
dasselbe Bild —
`grep -h '"tool":"Agent"' .harness/state/spans/af347d77_917b_4841_b85f_b234f28e4e27.jsonl` →
eine Zeile, `duration_ms: 14`, `result_bytes: 437`, keine Rolle, keine Zähler.

## 6. Kontroll-Lauf — wird `updatedInput` überhaupt übernommen?

Der teuerste Fehler dieser Messung wäre ein Negativ aus der falschen Ursache (Plan §6): ein
verworfenes `updatedInput` sähe genauso aus wie ein ignoriertes Feld. Der Dialog aus Lauf 1
beweist die Übernahme nicht — deshalb eine zweite Sonden-Fassung am selben Hook-Pfad (die
Hook-Liste der offenen Sitzung blieb gültig, der Befehl liest die Datei frisch), die **nichts
parst** und ein statisches `updatedInput` mit einem Marker in `description` zurückgibt — verbatim:

```bash
#!/usr/bin/env bash
# pretooluse-updatedinput-sonde.sh — KONTROLL-Fassung (slice-086), temporaer, uncommittet.
#
# Zweck: unterscheidet die zwei Ursachen eines negativen Ausgangs (Plan §6):
# wird updatedInput ueberhaupt uebernommen? Diese Fassung parst NICHTS und gibt
# ein statisches updatedInput mit einem Marker in description zurueck. Erscheint
# der Marker in der Tool-Zeile der Session, ist updatedInput uebernommen — dann
# ist das ignorierte run_in_background die Ursache des Negativs, nicht ein
# verworfenes updatedInput.
#
# Einziger Ausgang ist stdout; die Sonde schreibt in keine Datei.
set -euo pipefail

cat > /dev/null   # stdin konsumieren, Payload wird nicht gelesen

printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"KONTROLL-Sonde slice-086: updatedInput ersetzt die Eingabe (Marker SONDE-KONTROLLE-9d4b in description)","updatedInput":{"description":"SONDE-KONTROLLE-9d4b","prompt":"Gib als Endergebnis genau das Wort OK zurück.","subagent_type":"Explore","run_in_background":false}}}'
```

**Wirkung dieser Fassung, ausgesprochen:** sie ersetzt **jeden** `Agent`-Aufruf der Sitzung durch
den statischen Auftrag — `description`, `prompt` und `subagent_type` des realen Aufrufs werden
verworfen, nicht durchgereicht. Sie ist nicht die Sonde aus DoD (1), sondern ein Instrument für
genau diese eine Frage, und sie gehört in keine Arbeitssitzung: wer sie verdrahtet lässt, bekommt
für jeden Subagenten-Aufruf das Ergebnis eines anderen Auftrags, und nur der `ask`-Dialog zeigt
es. (Aufgezeichnet wird auch hier nichts — der verworfene Prompt wird nicht gelesen.)

Beobachtet (Screenshot-belegt), in derselben offenen Sitzung `d3ef8106…`:

- Die Sitzung forderte `Explore(Explore-Agent: nur OK zurückgeben)` an; die Tool-Zeile des
  Bestätigungs-Dialogs zeigte **`Explore(SONDE-KONTROLLE-9d4b)`** — die ersetzte Eingabe, vor der
  Ausführung angezeigt.
- Nach der Bestätigung lief der Agent unter dem Marker-Namen durch („Agent "SONDE-KONTROLLE-9d4b"
  finished") — die Ersetzung durchdrang den ganzen Lauf.
- **Trotzdem: „Backgrounded agent".** Span (`seq 2` desselben Stroms, Kommando bei Lauf 1):
  `duration_ms: 3`, `result_bytes: 360`, kein
  `spawned_role`, keine Zähler:

```json
{"seq":2,"ts":"2026-08-21T18:34:31Z","event":"PostToolUse","tool":"Agent","tool_use_id":"toolu_015bN4ALawqETDt81J517aen","session":"d3ef8106-bc2d-4a6e-8bd0-72c91c4b813d","agent":"","agent_type":"","agent_role":"","slice":["slice-086-vordergrund-per-updatedinput"],"requirement":["LH-QA-01","LH-QA-03"],"adr":["ADR-0011","ADR-0019"],"branch":"main","commit":"3f27b7c7f802","status":"ok","permission_mode":"auto","duration_ms":3,"result_bytes":360,"model_version":"claude-opus-5[1m]"}
```

**Was von der Übernahme im Repo nachfahrbar ist — und was nicht.** Die Übernahme ist eine
Sicht-Beobachtung am Dialog und an der Fertigmeldung. Im Repo trägt sie nichts: der Span führt
nach ADR-0011 weder `description` noch Betriebsart; ein Screenshot ist kein Artefakt dieses Repos;
und die einzige Datei, die den ausgeführten Aufruf mit seiner Eingabe aufzeichnet — das
Sitzungs-Transkript — ist **als Quelle ausgeschlossen** (`spec/spezifikation.md` §5 Abweichung 1:
*„der `transcript_path` wird deshalb weder erfasst noch gelesen"*, Abweichung 5; ADR-0012
Alternative D; ADR-0019 Annahme (c) — die Umkehr ist dort eine Erlaubnis des Auftraggebers, kein
Sensor) und wird hier weder gelesen noch gezählt. **Reproduzierbar ist die Beobachtung allein durch
Wiederholung:** die Kontroll-Fassung in einer danach gestarteten Sitzung verdrahten und die
Tool-Zeile des Dialogs lesen. Das ist eine Eigenschaft des Gegenstands, nicht dieses Dokuments —
sie steht in §7 als Grenze und geht mit §8 an den Architect.

## 7. Ergebnis und Grenzen

**Die eine Beobachtung, am Span gelesen:** Der `Agent`-Span eines Laufs, dessen Eingabe per
`updatedInput` nachweislich ersetzt wurde — durch eine Hook-Ausgabe, die `"run_in_background":
false` trug —, führt weder
`spawned_role` noch `input_tokens`, `output_tokens`, `cache_creation_input_tokens` oder
`cache_read_input_tokens`. **Der Weg über `PreToolUse`-`updatedInput` stellt die Vordergrund-Form
nicht her.**

Grenzen, benannt:

- Ob das Feld vor dem Start aus der Eingabe gestrippt oder beim Start ignoriert wird, ist von
  außen nicht unterscheidbar — für den Vertrag gleichwertig: es wirkt nicht.
- Momentaufnahme: gilt am 2026-08-21 für die Werkzeug-Fassung der zitierten Span-Zeilen. Ändert
  das Agenten-Werkzeug seinen Vertrag, ist die Messung neu zu fahren.
- Der `make span-report` steht daneben, nicht an Stelle der Span-Lektüre: er zählt einen Lauf
  schon mit einem gesetzten Zähler als gedeckt und fragt nicht nach der Rolle.
- **Die Kontroll-Beobachtung — dass `updatedInput` übernommen wurde — ist mit den Mitteln
  dieses Repos prinzipiell nicht belegbar.** Sie stützt sich auf die Sicht am Dialog und an der
  Fertigmeldung; kein Span trägt sie, ein Screenshot ist kein Artefakt, und die Datei außerhalb,
  die sie trüge, ist als Quelle ausgeschlossen (§6). Das ist eine Eigenschaft des Gegenstands:
  jeder weitere Träger, auf den ein Beleg geschoben würde, ist entweder leer oder gesperrt. Sie
  ist die einzige Gegenkraft gegen ein Negativ aus der falschen Ursache (Plan §6) und steht
  deshalb hier als Grenze: wer sie nicht glaubt, wiederholt den Kontroll-Lauf, statt den Span zu
  deuten.
- **Der Span ist hier Ablese-Ort, obwohl eine aktive ADR ihm den Beleg-Status abspricht.**
  ADR-0011 Festlegung 3 sagt *„Kein Beleg-Status. Ein Span ist kein Review-Gegenstand und keine
  Quelle für eine Zusage im Sinne von AGENTS.md §3.6"*; ADR-0019 Festlegung 4 und CO-002 ordnen
  an, die Messung *„an der `Agent`-Zeile des Span-Bestands"* abzulesen. Dieses Dokument folgt der
  Anordnung und belegt keine Zusage damit — es berichtet eine Beobachtung. Welchen Rang die zwei
  Stellen zueinander haben und ob eine solche Beobachtung eine permanente Entscheidung tragen darf,
  entscheidet es nicht; das geht mit §8 an den Architect.

**Nebenbefund mit eigenem Wert:** Die Hook-*Liste* einer Sitzung wird beim Session-Start
eingefroren (Lauf 0); der Hook-*Befehl* wird bei jedem Feuern frisch von Platte gelesen (§6).
Jeder künftige Messaufbau an `.claude/settings.json` braucht eine danach gestartete Sitzung.

## 8. Übergabe an den Architect (DoD 3, negativer Zweig)

Der benannte Auftrag: **Es bleiben nur die zwei Trigger im fremden Vertrag** (das Agenten-Werkzeug
führt seine Vordergrund-Form oder seine Telemetrie selbst; ein Hook-Ereignis liefert die Zähler
ohne eigenen Aufwand). Der dritte Weg — die Vordergrund-Form per `PreToolUse`-Hook herstellen —
liegt nach dieser Messung nicht mehr in unserer Hand: das Feld ist im Eingabe-Schema nicht mehr
geführt und in einem übernommenen `updatedInput` wirkungslos. Modul-7-Frage 2 (Temporalität)
kippt damit für `CO-002` auf *Nein*, und `CO-002` ist in eine Folge-ADR zu überführen (der
Carveout endet in `done/`, die Zellen der welle-09-Matrix, die auf seine Frage zeigen, lesen die
Antwort dann dort). Der Status-Wechsel und der `git mv` des Carveouts gehören dem Implementer des
Folge-Schnitts, die ADR dem Architect — dieser Slice liefert die entscheidbare Frage samt
Beobachtung, sonst nichts.

**Mit in die Übergabe — ein Punkt, den die Folge-ADR zu tragen hat und dieser Slice nur benennt:**
der Rang zwischen ADR-0011 Festlegung 3 (*kein Beleg-Status* des Spans) und ADR-0019 Festlegung 4 /
CO-002 (der Span als Ablese-Ort der Messung). Die Beobachtung dieses Dokuments steht auf drei
Span-Zeilen eines gitignorierten Bestands ohne Prüfsumme — und ihre Kontroll-Beobachtung, die
Übernahme von `updatedInput`, ist mit den Mitteln dieses Repos **prinzipiell nicht belegbar** (§6,
§7: der Span trägt sie nicht, ein Screenshot ist kein Artefakt, das Transkript ist als Quelle
ausgeschlossen). Ob das eine permanente Entscheidung tragen darf — oder ob die Entscheidung auf
dem steht, was unabhängig davon gilt: das Feld ist im Eingabe-Schema nicht geführt, und beide
fremden Wege sind unverändert —, sagt der Architect, nicht dieses Dokument.
