# Implementation-Review slice-059 — Telemetrie-Erfassung, Spans per Agenten-Hook

**Datum:** 2026-07-28 · **Rolle:** Reviewer (Modul 10) · **Reviewer-Skill:** 1.4.0 ·
**Baseline:** v3.5.2

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Prüfgegenstand** | Commit `e07624a` — „feat: slice-059 — Telemetrie-Erfassung, Spans per Agenten-Hook" |
| **Commit-Range** | `origin/main..HEAD` = genau ein Commit (`e07624a`) |
| **Neue Dateien** | `harness/tools/span-fields.awk`, `harness/tools/span-emit.sh`, `test/span-emit.bats`, `test/mutations/107-span-klemme-entfernt.sh`, `test/mutations/108-span-schema-offen.sh` |
| **Geänderte Dateien** | `.claude/settings.json`, `harness/conventions.md` (`MR-018`) |
| **Slice-Plan** | `docs/plan/planning/in-progress/slice-059-telemetrie-erfassung-hook.md` |
| **Referenzierte aktive ADRs** | `ADR-0011` (Accepted, immutabel), `ADR-0004`, `ADR-0003` |
| **Betroffene Anforderungen** | `LH-QA-03`, `LH-QA-01`, `LH-QA-02` |
| **Hard Rules** | `AGENTS.md` §3.1, §3.2, §3.4, §3.5, §3.6 |
| **Konventionen** | `MR-002`, `MR-003`, `MR-005`, `MR-017`, `MR-018` (neu) |
| **Vorherige Findings derselben Klasse** | `docs/reviews/2026-07-28-adr-0011-proposed-review.md` und `…-runde-2.md` … `…-runde-6.md` (sechs Runden, HIGH 2→3→1→3→2→0) |
| **Nicht geprüft (andere Rolle)** | DoD-Abhakung, Gate-Lauf-Bestätigung → Verifikation (Modul 11) |

**Wiederkehrende Fehlerklasse dieses Autors, aus den sechs ADR-Runden:** dreimal wurde eine
**Sensor-Lage behauptet, die nicht gemessen war** (Runde 5 hielt fest: *„dreimal wurde eine
`grep`-Trefferliste als Vollständigkeitsaussage gelesen, statt den Sensor zu fahren"*). Dieser
Review hat deshalb **jede** Sensor-, Kosten- und Abdeckungs-Aussage des Diffs an ihrer Quelle
nachgemessen — der Emitter wurde mit selbst gebauten Payloads gefüttert, die Mutation 107 in
einer Kopie außerhalb des Repos wirklich angewandt und ihr Ergebnis in getrennten Kanälen
gemessen. Die Klasse ist **nicht** verschwunden: fünf der sieben HIGH unten sind Aussagen, die
an ihrer Quelle nicht halten.

**Gefahrene Sensoren (nur `make`-Targets, Docker-only):** `make docs-check` (235/0),
`make shell-lint` (clean), `make comment-claims` (32/0), `make test-bats` (138/138, davon elf
`span:`-Wächter, ok 128–138). Zusätzlich Live-Beobachtung: der Hook ist in dieser Sitzung aktiv
und hat 23 echte Spans in zwei Strömen erzeugt.

---

## Findings

### HIGH-1 — der fail-closed Default hängt am FELDNAMEN, nicht am Werkzeug-Namen

- **Kategorie:** HIGH (Verstoß gegen eine aktive ADR)
- **Quelle:** `ADR-0011` Festlegung 2
- **Pfad:** `harness/tools/span-fields.awk:96-106`
- **Befund:** Der Scanner entscheidet über die Argument-Erfassung ausschließlich am
  Feldnamen innerhalb von `tool_input` (`file_path`, `notebook_path`, `command`) und liest den
  `tool_name` für diese Entscheidung **gar nicht**. `ADR-0011` Festlegung 2 legt das Gegenteil
  fest: *„Der Default entscheidet über den Werkzeug-NAMEN, nicht über eine Gattung: die Zeilen
  oben sind auf konkrete Namen abzubilden, und was nicht namentlich gelistet ist, fällt hierher —
  eine Gattungs-Zuordnung ließe Argumente genau dort durch, wo ein Name in keine Gattung passt."*
  Die Umsetzung ist genau die verbotene Gattungs-Zuordnung, nur über Feld- statt Tool-Namen.
  `MR-018:843` spiegelt die Fehlaussage in die Doku: *„nur bei namentlich gelisteten
  Datei-Werkzeugen"* — kein Werkzeug ist irgendwo namentlich gelistet.
- **Failure-Szenario (gemessen):** Payload eines Werkzeugs, das in keiner Zeile der
  Festlegungs-2-Tabelle steht:
  `{"tool_name":"mcp__db__run","tool_input":{"command":"psql --password=SUPERSECRET-XYZ -c select"}}`
  → Span `…"tool":"mcp__db__run",…,"program":"psql","argc":3`. Und
  `{"tool_name":"mcp__evil__x","tool_input":{"file_path":"README.md"}}`
  → Span mit `"path":"README.md","bytes":5737,"sha256_16":"2af58513fdda10f6"`. Beide hätten nach
  Festlegung 2 **nur Name und Status** tragen dürfen.
- **Verifizierbar:** ja — die Payloads oben gegen `harness/tools/span-emit.sh` mit gesetztem
  `SPAN_DIR`; kein bestehender Gate-Lauf färbt das heute rot (siehe HIGH-2).

### HIGH-2 — der Wächter des fail-closed Defaults kann die Eigenschaft nicht messen

- **Kategorie:** HIGH (§3.6-Verstoß im Sicherheitspfad; Test misst die Implementierung, nicht die
  Eigenschaft)
- **Quelle:** `AGENTS.md` §3.6, `ADR-0011` Fitness Function Zeile 2
- **Pfad:** `test/span-emit.bats:88-95`, gestützt von `test/mutations/108-span-schema-offen.sh:15`
- **Befund:** Der Test heißt *„span: ein unbekanntes Werkzeug gibt nur Name und Status preis"*,
  füttert aber eine `Task`-Payload, deren Felder (`prompt`, `subagent_type`) schon deshalb nicht
  erfasst werden, weil **kein** Werkzeug sie erfasst — der Test misst also, dass `prompt` nicht in
  der Feldliste steht, nicht, dass ein unbekanntes Werkzeug fail-closed behandelt wird. Das ist
  exakt das §3.6-Muster *„ein Test, dessen Name eine Eigenschaft behauptet, muss die Eigenschaft
  messen, nicht ihre heutige Implementierung"*. `MR-018:858` führt diesen Test unter *„Bewacht:
  … fail-closed Default"* auf.
- **Failure-Szenario (gemessen):** Der Test bleibt grün, während die zugesagte Eigenschaft
  gebrochen ist — HIGH-1 ist unter `make test-bats` (138/138) und `make mutate` (104 ok/0) heute
  nicht sichtbar. Ein Werkzeug wie `mcp__db__run` mit `command` gibt seine Argumente preis, ohne
  dass ein Wächter fällt.
- **Verifizierbar:** ja — `make test-bats` bleibt grün, obwohl die HIGH-1-Payloads Argumente
  durchlassen.

### HIGH-3 — die Folgenummer kann konstruktionsbedingt keine Lücke zeigen

- **Kategorie:** HIGH (Verstoß gegen eine aktive ADR; Zusage ohne Abdeckung)
- **Quelle:** `ADR-0011` Folgepflicht 4
- **Pfad:** `harness/tools/span-emit.sh:97-99`
- **Befund:** Die Folgenummer wird als `wc -l` **der Span-Datei selbst** plus eins gebildet. Sie
  ist damit aus dem Bestand **abgeleitet** statt vergeben: die Nummernfolge ist immer dicht
  1…N, unabhängig davon, wie viele Emitter zwischendurch gestorben sind. Eine Lücke ist
  **strukturell unmöglich**. Der Kommentar direkt darüber sagt das Gegenteil zu (*„Folgenummer
  ZUERST vergeben: stirbt der Prozess danach, fehlt der Eintrag und die Luecke ist sichtbar"*),
  ebenso `MR-018:831` (*„damit der **Leser** eine Lücke sieht"*) und `ADR-0011` Folgepflicht 4
  (*„Die Nummer wird als Erstes vergeben, vor jeder anderen Arbeit des Emitters"*). Sie wird
  faktisch **zuletzt** vergeben — nach `cd`, `cat`, awk-Parse, Slice-Ableitung, `mkdir` und dem
  Anlegen der Datei.
- **Failure-Szenario (gemessen):** Drei Aufrufe in einen leeren Strom, dazwischen ein verlorener
  Span (Emitter stirbt nach der Nummernbildung) → Bestand `"seq":1 "seq":2 "seq":3`. Der Leser
  sieht Vollständigkeit; der Verlust ist unsichtbar. Genau der Zustand, den Folgepflicht 4
  ausschließen soll (*„sonst entsteht ein Log, das lückenhaft ist und vollständig aussieht"*).
- **Verifizierbar:** ja — ein Mutations-Fall „der Emitter überspringt einen Aufruf" (in der
  ADR-Fitness-Function gefordert, im Diff nicht vorhanden) bliebe unter jeder Ausprägung grün.

### HIGH-4 — kein eigener Hook-Timeout gesetzt

- **Kategorie:** HIGH (Verstoß gegen eine aktive ADR)
- **Quelle:** `ADR-0011` Festlegung 6
- **Pfad:** `.claude/settings.json:14-35`
- **Befund:** Festlegung 6 verlangt für den Erfassungs-Hook *„einen **eigenen harten Timeout
  deutlich unterhalb des Werkzeug-Defaults** (dokumentiert sind 600 s — als Grenze für ein
  Audit-Skript unbrauchbar)"*. Die beiden neuen Hook-Einträge tragen nur `type` und `command`;
  `grep -c timeout .claude/settings.json` → `0`. Das `timeout`-Feld je Hook ist in den
  Vorrunden-Reports verbatim aus der Werkzeug-Doku zitiert
  (`…-runde-5.md:597`, `…-runde-6.md:511`), war dem Autor also bekannt. Weder `MR-018` noch die
  Commit-Message nennen die Auslassung als Abweichung.
- **Failure-Szenario:** Ein `Read` auf eine mehrere GB große Datei lässt den Emitter in
  `sha256sum` (`span-emit.sh:108`) hängen; ohne eigenen Timeout läuft er bis zum 600-s-Default
  des Werkzeugs. Der Lauf, den die Telemetrie nur beobachten soll, steht bis zu zehn Minuten je
  Tool-Call — die Fail-open-Zusage („darf einen Lauf niemals blockieren oder spürbar
  verzögern") ist damit auf genau dem Pfad offen, für den Festlegung 6 die Grenze gezogen hat.
- **Verifizierbar:** ja — `.claude/settings.json` gegen Festlegung 6 lesen; kein Gate prüft es.

### HIGH-5 — Mutation 107 nimmt die Exit-Klemme nicht weg, behauptet es aber

- **Kategorie:** HIGH (§3.6: Zusage ohne rot gesehenes Gegenbeispiel; `ADR-0011`-Fitness-Function-Zeile
  unerfüllt)
- **Quelle:** `AGENTS.md` §3.6, `ADR-0011` Fitness Function (*„Die Klemme wird entfernt (der
  Emitter reicht seinen inneren Exit-Code durch) — der Wächter muss rot werden; ohne diesen Fall
  wäre Festlegung 6 eine Absicht"*)
- **Pfad:** `test/mutations/107-span-klemme-entfernt.sh:15`, Ziel `harness/tools/span-emit.sh:131-132`
- **Befund:** Das `sed` ersetzt nur Zeile 131 (`( emit_span ) >/dev/null 2>&1 || true` →
  `emit_span`). Zeile 132 (`exit 0`) bleibt **unangetastet**. Der mutierte Emitter kann seinen
  inneren Exit-Code deshalb weiterhin nicht durchreichen — die Fitness-Function-Zeile ist nicht
  umgesetzt. Der Fallkopf behauptet das Gegenteil (*„Damit erreicht jede innere Stoerung den
  Aufrufer … und ein Exit 2 blockt den Tool-Call"*), und `span-emit.sh:15` sagt *„Beides ist
  bewacht … test/mutations/107"* für stdout **und** Exit-Code zu.
- **Failure-Szenario (gemessen an einer Kopie außerhalb des Repos):** Nach Anwendung des `sed`
  und Aufruf mit `PATH=/nonexistent`: **Exit-Code 0, stdout 0 Bytes**, 51 Bytes auf **stderr**.
  Im gesunden Lauf: Exit 0, stdout 0 Bytes, stderr 0 Bytes. Der Wächter wird rot, weil bats in
  `run` stderr in `$output` mischt — also wegen der **stderr**-Umleitung, nicht wegen des
  Entscheidungs-Kanals stdout und nicht wegen des Exit-Codes. Fiele jemand künftig die
  `exit 0`-Zeile weg, meldete `make mutate` weiterhin `ok`.
- **Verifizierbar:** ja — `sed`-Ausdruck aus 107 auf eine Kopie anwenden und Exit-Code/stdout
  getrennt messen.

### HIGH-6 — Modul-15-Pflichtfeld „PR" fehlt ohne erklärte Abweichung

- **Kategorie:** HIGH (Verstoß gegen eine aktive ADR; genau die Klasse, die der
  welle-09-Plan-Review als HIGH gefunden hat)
- **Quelle:** `ADR-0011` Festlegung 1.1 und 1.5, `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md:33`
- **Pfad:** `harness/conventions.md:829-857` (`MR-018`-Feldtabelle und Abweichungs-Liste)
- **Befund:** Modul 15 fordert für den Tool-Call-Span *„Korrelations-IDs zu Slice/**PR**/Agent-Rolle"*.
  `ADR-0011` Festlegung 1.1 bindet beide Modul-15-Listen unverkürzt und 1.5 verlangt: *„Was auch
  nach der Ableitung nicht erreichbar ist, wird begründet dokumentiert, nicht weggelassen. Eine
  stillschweigend verkürzte Feldliste ist die Fehlerklasse, die der welle-09-Plan-Review als HIGH
  gefunden hat."* `MR-018` führt **zwei** erklärte Abweichungen (Cache-Status, `agent_type`);
  der PR-/Branch-/Commit-Bezug fehlt in der Tabelle **und** in der Abweichungs-Liste — er wird
  weder erfasst noch als unerreichbar begründet.
- **Failure-Szenario:** Ein Auswerter (slice-060) soll Token-Kosten je PR ausweisen und findet im
  Span keinen Anker; die `MR-018`-Tabelle liest sich als vollständige Umsetzung des
  Pflicht-Minimums und nennt die Lücke nicht — der nächste Leser hält den Mindestsatz für
  erfüllt.
- **Verifizierbar:** ja — `MR-018`-Tabelle gegen `modul-15-observability.md:33` legen.

### HIGH-7 — `program` ist nicht das Programm: eine Inline-Env-Zuweisung landet verbatim im Span

- **Kategorie:** HIGH (MEDIUM-Beobachtung, im Sicherheitspfad eine Stufe hoch — Reviewer-Skill
  §Kontext-Eskalation)
- **Quelle:** `ADR-0011` Festlegung 2 (*„Damit wandert **kein Byte fremden Inhalts** ins Log"*),
  slice-059 §6 (*„Ein Audit-Log, das Secrets sammelt, ist ein Schaden, kein Sensor"*)
- **Pfad:** `harness/tools/span-fields.awk:100-106`
- **Befund:** Als „Programm" wird das erste **Whitespace-Feld** der Kommandozeile ausgegeben. Bei
  einer Kommandozeile mit vorangestellter Umgebungs-Zuweisung ist das erste Feld die Zuweisung
  **samt Wert**, nicht das Programm. Der Kommentar an der Stelle (*„NUR das erste Token (das
  Programm)"*) und die Commit-Message (*„KEIN BYTE FREMDEN INHALTS, und das ist gemessen, nicht
  zugesagt"*) sind an dieser Payload-Form falsch.
- **Failure-Szenario (gemessen):**
  `{"tool_name":"Bash","tool_input":{"command":"GITHUB_TOKEN=ghp_SECRET_abc123 gh pr create"}}`
  → Span `…"program":"GITHUB_TOKEN=ghp_SECRET_abc123","argc":3`. Das Zugangsdatum steht damit
  dauerhaft im Audit-Log und überlebt seine Rotation — Grund 1 der drei in Festlegung 2 benannten
  realen Gründe. `test/span-emit.bats:79-86` deckt den Fall nicht ab: dort steht das Secret in
  den Argumenten, nicht im ersten Feld.
- **Verifizierbar:** ja — Payload oben gegen den Emitter; kein bestehender Wächter fällt.

### MEDIUM-1 — Lese-Werkzeuge bekommen Länge und Inhalts-Hash, obwohl die Tabelle nur den Pfad vorsieht

- **Kategorie:** MEDIUM (Über-Erfassung gegen ein geschlossenes Schema)
- **Quelle:** `ADR-0011` Festlegung 2 (Zeile *Lese-Werkzeuge → erfasst wird: **Pfad***) und
  Festlegung 1.3 (*„erfasst wird, was darin steht — sonst nichts"*)
- **Pfad:** `harness/tools/span-emit.sh:105-109`, Ausgabe `:120-122`
- **Befund:** `bytes` und `sha256_16` werden für **jeden** Span mit einem `path` berechnet, ohne
  Unterscheidung zwischen Schreib- und Lese-Werkzeug. Die Festlegungs-2-Tabelle gibt den
  Inhalts-Hash nur den Schreib-Werkzeugen; für Lese-Werkzeuge steht dort ausschließlich der Pfad.
  `ADR-0011` nennt den Hash zugleich ein *„Bestätigungs-Orakel („war es dieser Wert?")"*.
- **Failure-Szenario (live gemessen, Strom dieser Sitzung):** Ein reiner `Read` auf
  `.harness/skills/reviewer.md` hinterlässt
  `"path":"…/reviewer.md","bytes":4913,"sha256_16":"bc6801399433780e"` — ein
  Bestätigungs-Orakel über eine Datei, die nur gelesen wurde. Bei einem `Read` auf eine Datei
  außerhalb des Repos (die Payload steuert den Pfad, `-f` ist die einzige Prüfung) entsteht
  dasselbe Orakel über fremde Dateien.
- **Verifizierbar:** ja — `.harness/state/spans/*.jsonl` nach `"tool":"Read"` filtern.

### MEDIUM-2 — `requirement.id` kommt aus der ganzen Slice-Datei, nicht aus der `Bezug:`-Zeile

- **Kategorie:** MEDIUM (Spec-Treue-Lücke der Messmethode)
- **Quelle:** `ADR-0011` Festlegung 1.4 (*„`requirement.id` aus der `**Bezug:**`-Zeile der
  Slice-Datei"*)
- **Pfad:** `harness/tools/span-emit.sh:67-73`
- **Befund:** Der Kommentar sagt *„requirement.id aus der Bezug-Zeile derselben Slices"* zu; der
  Code greppt `LH-[A-Z]{2}-[0-9]{2}` über die **komplette** Datei. Dass es für slice-059
  identisch aussieht, ist ein Zufall des heutigen Inhalts (die Datei nennt nur `LH-QA-03`).
- **Failure-Szenario (gemessen an einem realen Slice):** Dieselbe Ableitung auf
  `docs/plan/planning/done/slice-032-command-guard-emit.md` angewandt: Bezug-Zeile führt
  `LH-FA-06 LH-QA-03`, der Emitter-Grep liefert `LH-FA-06 LH-FA-08 LH-QA-03`. Der Span schriebe
  `LH-FA-08` einer Anforderung zu, die der Slice nur in der Prosa erwähnt — der Auswerter
  attribuierte Kosten auf eine Anforderung, die nicht im Bezug steht.
- **Verifizierbar:** ja — Vergleich der zwei `grep`-Läufe an einem Slice mit Prosa-IDs.

### MEDIUM-3 — nebenläufige Emitter desselben Stroms vergeben dieselbe Folgenummer und zerreißen Zeilen

- **Kategorie:** MEDIUM (Reproduzierbarkeits-/Integritätsrisiko, `LH-QA-02`)
- **Quelle:** `ADR-0011` Folgepflicht 4 (*„eine Doppelvergabe erzeugt keine Lücke, sieht also aus
  wie Vollständigkeit"*)
- **Pfad:** `harness/tools/span-emit.sh:99` (Lesen) und `:112-126` (Schreiben)
- **Befund:** `wc -l` und der anschließende Append sind ein ungeschütztes Read-modify-write; die
  Span-Zeile entsteht zudem aus bis zu elf getrennten `printf`-Aufrufen in einen gemeinsam
  geöffneten Anhänge-Deskriptor. Die Strom-Trennung je (Sitzung, Agent) schützt gegen Subagenten,
  nicht gegen parallele Tool-Calls **desselben** Agenten.
- **Failure-Szenario (gemessen):** 25 gleichzeitige Emitter auf denselben Strom → 25 Zeilen, davon
  **6 doppelt vergebene Folgenummern** (`seq` 1, 4, 5, 14, 15, 21 je mehrfach) und **8
  strukturell kaputte Zeilen** (Fragmente wie `,"status":"ok","program":"ls","argc":2}` ohne
  Zeilenanfang). Der Auswerter aus slice-060 liest kein gültiges JSONL mehr.
  **Ehrlich zur Eintrittswahrscheinlichkeit:** in den 23 live erzeugten Spans dieser Sitzung trat
  keine Kollision auf, obwohl mehrere Paare denselben Zeitstempel-Sekundenwert tragen
  (`seq` 5/6, 7/8, 9/10, 15/16, 19/20) — das Werkzeug scheint die Hooks heute zu serialisieren.
  Diese Serialisierung ist eine Eigenschaft des Werkzeugs, keine des Emitters, und in keiner
  Quelle dieses Repos zugesagt.
- **Verifizierbar:** ja — n-fach paralleler Aufruf gegen einen Strom.

### MEDIUM-4 — `SPAN_DIR` ist im Betrieb setzbar; die Kopplung an den gitignorierten Ort ist nur textuell bewacht

- **Kategorie:** MEDIUM (Beobachtung im Gate-Pfad `MR-003`)
- **Quelle:** `MR-003`, `ADR-0011` Festlegung 3, `AGENTS.md` §3.6
- **Pfad:** `harness/tools/span-emit.sh:81-85`, Wächter `test/span-emit.bats:121-125`
- **Befund:** Der Ablageort ist über die Umgebungsvariable `SPAN_DIR` ohne jede Prüfung
  überschreibbar; ein Hook erbt die Umgebung des Agenten-Prozesses. Der Kommentar *„Im Betrieb
  setzt ihn niemand"* ist eine Zusage ohne Gegenbeispiel. Der Wächter, der die Kopplung sichern
  soll, misst zwei **Textstellen** (`grep -c 'SPAN_DIR:-\.harness/state/spans' "$EMIT"` und
  `grep -c '^\.harness/state/$' "$REPO/.gitignore"`), nicht die Eigenschaft — genau das
  §3.6-Muster „prüft ein Implementierungsdetail statt der Eigenschaft". `git check-ignore` auf
  den real geschriebenen Pfad wäre die Messung; sie findet nicht statt.
- **Failure-Szenario:** Ein Nutzer hat `SPAN_DIR` (generischer Name, kein Präfix) in seiner Shell
  exportiert oder setzt sie auf einen getrackten Pfad. Dann liegt ab dem ersten Tool-Call ein
  Span im Arbeitsbaum, `working-tree-hash.sh` (getrackt **und** untracked, `--exclude-standard`)
  ändert sich bei **jedem** Tool-Call, und der Stop-Hook blockiert sich selbst — exakt der
  Selbstblockierer, den `ADR-0011` Festlegung 3 und slice-059 §6 ausschließen wollen. Beide
  bats-Zusicherungen bleiben dabei grün.
- **Verifizierbar:** ja — `SPAN_DIR=docs make …` und danach `harness/tools/working-tree-hash.sh`
  vor/nach einem Tool-Call vergleichen.

### MEDIUM-5 — `status` meldet „ok" auf einem Fehlschlag-Ereignis, wenn `error` kein Top-Level-String ist

- **Kategorie:** MEDIUM (Bezugslücke einer Akzeptanzanforderung: `tool.result.status`)
- **Quelle:** `MR-018:836` (`status` → *„Ging es gut?"*), Modul 15 Mindestfeld
  `tool.result.status`
- **Pfad:** `harness/tools/span-fields.awk:95`, Auswertung `harness/tools/span-emit.sh:117`
- **Befund:** `error` wird ausschließlich erkannt, wenn es auf **Ebene 1** als **String** steht
  (`emit("error","1")` feuert nur beim Schließen eines Strings). Jede andere Form —
  Objekt, Zahl, Feld in einem Unterobjekt — bleibt unsichtbar, und `status` fällt auf `ok`
  zurück. Der Slice-Plan stützt `tool.result.status` genau auf dieses Feld
  (*„`PostToolUseFailure` liefert `error`"*), ohne dessen Form festzustellen.
- **Failure-Szenario (gemessen):**
  `{"hook_event_name":"PostToolUseFailure","tool_name":"Bash","error":{"message":"boom"},…}`
  → Span `…"event":"PostToolUseFailure",…,"status":"ok"`. Der Span widerspricht sich selbst; eine
  Auswertung „wie viele Tool-Calls sind gescheitert?" über `status` zählt null.
- **Verifizierbar:** ja — Payload oben gegen den Emitter; kein Wächter deckt den Fehlschlag-Pfad
  (alle elf `span:`-Tests fahren `PostToolUse` bzw. gar kein Ereignis).

### LOW-1 — kein `make`-Ziel zum Entfernen alter Span-Bestände

- **Kategorie:** LOW (Doku-/Umsetzungs-Drift)
- **Quelle:** `ADR-0011` Festlegung 3
- **Pfad:** `Makefile` (kein `span`-Ziel: `grep -n "span" Makefile` trifft nur d-checks eigenes
  `spans`-Modul in Zeile 168)
- **Befund:** Festlegung 3 spricht den Preis der Nicht-Aufräumung aus und benennt den Gegenpol:
  *„alte Bestände bleiben liegen, bis jemand sie **ausdrücklich** entfernt (ein `make`-Ziel, kein
  Automatismus)"*. Das Ziel existiert nicht. `span-emit.sh:92-95` legt die Datei nur an, wenn sie
  fehlt — da der Strom-Name die Sitzungs-Kennung trägt, ist der Aufräum-Zweig faktisch nie aktiv.
- **Failure-Szenario:** Nach einigen Wochen liegt je Sitzung und Subagent eine Datei in
  `.harness/state/spans/`; wer aufräumen will, hat kein dokumentiertes Mittel und löscht von Hand
  im Zustands-Bereich, in dem auch der Gate-Stempel und das Mutations-Lock liegen.
- **Verifizierbar:** ja — `make help` nennt kein solches Ziel.

### LOW-2 — `argc` zählt Felder, nicht Argumente

- **Kategorie:** LOW (latente Wartungsfalle)
- **Quelle:** Maintainability, `ADR-0011` Festlegung 2 (*„erstes Token + Argument-Anzahl"*)
- **Pfad:** `harness/tools/span-fields.awk:104-106`
- **Befund:** `split()` mit dem Regex-Trenner erzeugt bei führendem Whitespace ein leeres erstes
  Feld, das mitgezählt wird.
- **Failure-Szenario (gemessen):** `{"tool_input":{"command":"  ls -l"}}` → `program ls`,
  `argc 2`. Richtig wäre 1. Eine Auswertung, die Aufrufe nach Argument-Anzahl gruppiert, trennt
  identische Aufrufe je nach Einrückung in zwei Klassen.
- **Verifizierbar:** ja — Payload oben gegen `span-fields.awk`.

### LOW-3 — `chmod 600` erst nach dem Anlegen; ein bestehender Strom mit falschem Modus wird nie korrigiert

- **Kategorie:** LOW (latente Lücke)
- **Quelle:** `ADR-0011` Festlegung 3 (*„Modus restriktiv (`0600`), vom Emitter selbst gesetzt"*)
- **Pfad:** `harness/tools/span-emit.sh:92-95`
- **Befund:** Die Datei entsteht mit `: > "$file"` unter der geerbten `umask` (im gemessenen
  Zustands-Verzeichnis `775` → Datei `664`) und wird erst danach auf `600` gesetzt. Der `chmod`
  liegt zudem im `if`-Zweig „Datei existierte noch nicht" — ein Strom, dessen Datei aus anderer
  Quelle mit laxerem Modus vorliegt, wird nie nachgezogen.
- **Failure-Szenario:** Zwischen `: >` und `chmod` ist die Datei welt-lesbar; ein Leser mit
  passendem Timing sieht sie. Klein, aber es ist genau die Eigenschaft, die Festlegung 3 zusagt.
  Der Wächter `test/span-emit.bats:110-114` misst nur den Endzustand nach dem vollständigen Lauf.
- **Verifizierbar:** ja — `umask 000` setzen und `stat` zwischen Anlegen und `chmod` beobachten.

### INFO-1 — der Emitter hasht payload-gesteuerte Pfade auch außerhalb des Repos

- **Kategorie:** INFO (dokumentationswürdige, undokumentierte Annahme)
- **Quelle:** `ADR-0011` Festlegung 2 (*„im Repo zusätzlich ein Inhalts-Hash"*)
- **Pfad:** `harness/tools/span-emit.sh:106-108`
- **Befund:** Einzige Prüfung vor `wc -c`/`sha256sum` ist `[ -f "$path" ]`. Der Pfad stammt aus
  der Payload und kann absolut und außerhalb des Arbeitsverzeichnisses liegen. Die
  ebenen-abhängige Schärfe der ADR meint mit „im Repo" die **Ebene** (Dogfood vs. emittiert), was
  den Fall formal deckt — dass der Emitter dabei fremde Dateien liest, ist nirgends
  ausgesprochen.
- **Verifizierbar:** ja — Payload mit `file_path` außerhalb des Repos.

### INFO-2 — `make comment-claims` prüft Existenz, nicht Zähne

- **Kategorie:** INFO
- **Quelle:** `AGENTS.md` §4, `AGENTS.md` §3.6
- **Pfad:** `harness/tools/span-emit.sh:15`
- **Befund:** `make comment-claims` meldet 32/0 und bestätigt damit nur, dass die in Kommentaren
  genannten Sensoren **existieren**. Die Zusage *„Beides ist bewacht: … test/mutations/107"*
  passiert das Gate, obwohl die Exit-Code-Hälfte nicht bewacht ist (HIGH-5). Das ist keine
  Schwäche des Diffs, sondern die im Gate-Kopf selbst benannte Grenze — hier festgehalten, weil
  das grüne Gate leicht als Bestätigung der Zusage gelesen wird.
- **Verifizierbar:** ja — der Gate-Lauf ist grün, HIGH-5 besteht.

### INFO-3 — Host-Python im Slice-Prozess (nicht im Artefakt)

- **Kategorie:** INFO (Reproduzierbarkeit, `LH-QA-02`)
- **Quelle:** `CLAUDE.md` (Docker-only), `ADR-0011` Festlegung 4 (*„Toleranz des Guards ist keine
  Erlaubnis"*)
- **Pfad:** außerhalb des Repos (Scratchpad der Sitzung, `telemetry.py`), **nicht** im Diff
- **Befund:** Die Modul-15-Rohdaten-Bilanz, auf der die `MR-018`-Abweichung „Cache-Status"
  argumentiert, wurde mit einem ad-hoc Host-Python-Skript aus den Transkripten gezogen. Das
  **Artefakt** ist sauber: `span-emit.sh` und `span-fields.awk` nutzen ausschließlich
  `bash`/`awk`/Coreutils/`git`, die Festlegungs-4-Linie ist im Diff nicht überschritten.
- **Failure-Szenario:** Ein späterer Leser kann die Cache-Status-Begründung nicht mit
  Repo-Mitteln nachvollziehen — das Messwerkzeug ist weder committet noch über ein `make`-Ziel
  erreichbar.
- **Verifizierbar:** nein (Prozess-Beobachtung, kein Gate).

---

## Negativbefunde (geprüft, ohne Befund)

- **Die Klemme, Exit-Code und stdout, auf allen erreichbaren Fehlerpfaden.** Selbst gefahren:
  Müll-Payload (`kein json {{{`), leere Eingabe, `PATH=/nonexistent` (jeder innere Aufruf
  scheitert), fehlendes `git`, fehlendes `mkdir`/`wc`/`sha256sum`, unbeschreibbares `SPAN_DIR`.
  In **allen** Fällen: Exit 0, stdout 0 Bytes, stderr 0 Bytes. Die Konstruktion aus
  `span-emit.sh:131-132` (Subshell + Kanal-Verwurf + unbedingtes `exit 0`) hält, was Festlegung 6
  Setzung 1 und 2 verlangt. **Der Befund betrifft nur ihren Wächter** (HIGH-5), nicht die
  Eigenschaft selbst.
- **Der awk-Scanner desynchronisiert nicht.** Zeichenweise gegen sein eigenes Versprechen
  geprüft und gemessen: verschachtelte Objekte (`{"tool_response":{"tool_input":{"command":…}}}`
  → **nichts** erfasst, weil Ebene 3), Arrays innerhalb `tool_input`, geschweifte Klammern und
  Anführungszeichen **innerhalb** von String-Werten, `\"`/`\\`/`\n`/`\t`/`\r`/`\b`/`\f`,
  `\uXXXX` (vier Hex-Stellen werden korrekt übersprungen, der Wert wird durch `?` ersetzt — kein
  Überlaufen über das schließende `"` hinaus), doppelter Backslash am Wert-Ende. Die
  „erster Treffer gewinnt"-Regel verhindert, dass ein gleichnamiges Feld eines fremden
  Teilobjekts überschreibt. `esc()` deckt C0 1–31 vollständig ab; die erzeugten Zeilen sind
  valides JSON.
- **Datei-Inhalte passieren den Emitter nicht.** Der Kanarienvogel-Beleg der Commit-Message hält:
  `"content":"STRENG-GEHEIM-KANARIENVOGEL"` hinterlässt Pfad, Länge und Hash, der Inhalt taucht
  nirgends auf; `bytes`/`sha256_16` stammen nachweislich aus dem Dateisystem
  (`span-emit.sh:106-108`), nicht aus der Payload. Der `Write`/`Edit`/`MultiEdit`-Pfad und
  `NotebookEdit` (`new_source`) sind dicht. **Die zwei Lecks, die ich gefunden habe, liegen
  woanders** (HIGH-1, HIGH-7).
- **`MR-003`/Gate-Nachweis, Default-Pfad.** `working-tree-hash.sh` listet mit
  `git ls-files --cached --others --exclude-standard`; `.gitignore:5` führt `.harness/state/`.
  Ein Span unter `.harness/state/spans/` geht **nicht** in den Hash ein — gemessen an den 23
  live erzeugten Spans dieser Sitzung: `git status --porcelain` bleibt leer. Die Kopplung hält;
  bemängelt ist nur ihre Umgehbarkeit über `SPAN_DIR` (MEDIUM-4).
- **Modus 0600.** Live gemessen: beide Ströme in `.harness/state/spans/` stehen auf
  `-rw-------`, obwohl das Verzeichnis `775` ist. Festlegung 3 Auflage 1 ist erfüllt (Randfälle
  in LOW-3).
- **Strom-Trennung je (Sitzung, Agent).** Live belegt: `…-a854f893371f2efe5.jsonl` (Subagent) und
  `….jsonl` (Haupt-Kontext) sind getrennte Dateien mit je eigenem Nummernkreis; der Emitter fasst
  nur seine eigene Datei an. Festlegung 3 Auflage 2 ist umgesetzt.
- **`ADR-0011` Festlegung 4 (keine Installations-Abhängigkeit).** `span-emit.sh` und
  `span-fields.awk` verwenden `git`, `cat`, `awk`, `grep`, `sort`, `tr`, `mkdir`, `chmod`, `wc`,
  `date`, `sha256sum`, `cut`, `printf` — POSIX-Basis bzw. Coreutils, kein Container-Start je
  Tool-Call, keine zu installierende Laufzeit. Die Linie aus `ADR-0004` ist eingehalten.
- **`ADR-0011` Festlegung 5 (Emission).** `git show e07624a --stat -- internal/` ist leer: die
  emittierten Templates (`internal/emit/templates/enforce/settings.json`) sind **nicht** berührt.
  Das **Ob** der Emission bleibt korrekt bei slice-062 samt CR; der Diff nimmt ihm nichts vorweg.
- **`AGENTS.md` §3.2 (Lint-Suppression-Verbot).** Kein `# shellcheck disable`, kein `//nolint` in
  den fünf neuen Dateien; `make shell-lint` läuft clean über `harness/tools/*.sh` und
  `test/mutations/*.sh`.
- **`MR-005` (Ablage).** Emitter und Scanner liegen unter `harness/tools/`, die Wächter unter
  `test/` bzw. `test/mutations/` — konform, und ohne Form, die einen späteren Umzug nach
  `tools/harness/` erschwerte (slice-059 §6).
- **Keine Quell-Repo-Identität.** `grep -in "ai-harness-init\|pt9912\|github.com"` über beide
  neuen Werkzeuge: leer. Die Lehre aus slice-031/032/033 ist eingehalten.
- **Latenz-Schwelle.** Die Commit-Message nennt 24 ms je Aufruf gegen die 50-ms-Schwelle der ADR.
  Selbst nachgemessen (10 Läufe mit `file_path`-Payload auf eine 11-KB-Datei): 0,294 s gesamt,
  **~29 ms je Aufruf** — dieselbe Größenordnung, die Zusage hält. (Die Unbeschränktheit bei
  großen Dateien ist unter HIGH-4 erfasst, nicht hier.)
- **`slice.id`-Ableitung samt Randfällen.** Live belegt: `"slice":["slice-059-…"]` aus dem
  Lifecycle-Verzeichnis; die Liste-statt-Wert-Form und der Leer-Fall (`[]`) sind im Code angelegt
  (`span-emit.sh:56-66`). Festlegung 1.4 ist für `slice.id` erfüllt — bemängelt ist nur
  `requirement.id` (MEDIUM-2).
- **Mutation 108 färbt den benannten Test rot, und aus dem richtigen Grund.** Nachgestellt: der
  mutierte Scanner gibt für die `Task`-Payload `path VERTRAULICHER-PROMPT-TEXT` aus, die
  Zusicherung `[[ "$output" != *"VERTRAULICHER-PROMPT-TEXT"* ]]` fällt. Der Fall funktioniert wie
  beschrieben — **was er misst**, ist der Befund (HIGH-2), nicht **ob** er misst.
- **Sensor-Zahlen der Commit-Message.** Selbst nachgefahren bzw. an den Lauf-Protokollen geprüft:
  `make test-bats` 138/138 mit elf neuen `span:`-Wächtern (ok 128–138) — hält.
  `make mutate` 104 ok / 0 Befunde mit 107 und 108 als `ok … rot` — hält.
  `make docs-check` grün (ich messe 235/0, die Message nennt 234/0 — die Differenz ist eine
  Datei, kein Befund). `make comment-claims` 32/0 — hält.
  Live-Beleg „ein `Read`-Aufruf hat ebenfalls einen Span erzeugt, die Abdeckung geht über Bash
  hinaus" — hält (`"tool":"Read"` in beiden Strömen).
- **`PostToolUseFailure` existiert.** Der Verdacht eines halluzinierten Ereignisses ist
  **widerlegt**: die Vorrunden-Reports zitieren die Werkzeug-Doku verbatim
  (`…-runde-6.md:515`: *„**PostToolUseFailure** After a tool call fails"*). Die Registrierung mit
  leerem Matcher ist damit gedeckt; bemängelt ist nur die Auswertung des `error`-Feldes
  (MEDIUM-5).
- **Doc-Gate-Regeln.** `make docs-check` grün über 235 Dateien: alle Kennungen in `MR-018`
  (`ADR-0011`) sind linkpflichtig verlinkt, und die in Inline-Code genannten Pfade
  (`harness/tools/span-emit.sh`, `test/span-emit.bats`,
  `test/mutations/107-span-klemme-entfernt.sh`, `test/mutations/108-span-schema-offen.sh`)
  existieren — `codepaths.roots` deckt `harness/` ab.
- **`AGENTS.md` §3.4 (ADR immutabel) und §3.5 (keine Gate-Lockerung ohne ADR).** `ADR-0011` ist im
  Diff nicht angefasst; kein Gate wurde gelockert, keine Schwelle gesenkt.
- **`AGENTS.md` §3.1 / `LH-QA-01`.** Kein neues Gate-Target behauptet; die neuen Wächter hängen
  an bestehenden Targets (`make test-bats`, `make mutate`) mit nicht-leerem Prüfbereich.
- **`MR-017`.** Nicht berührt — es gilt für emittierte Prüfbereiche, und emittiert wird hier
  nichts.

---

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | **7** |
| MEDIUM | 5 |
| LOW | 3 |
| INFO | 3 |
| **Gesamt** | **18** |

**Verteilung nach Quelle:** `ADR-0011` Festlegung 2 → HIGH-1, HIGH-7, MEDIUM-1 ·
`ADR-0011` Festlegung 1 → HIGH-6, MEDIUM-2 · `ADR-0011` Festlegung 6 → HIGH-4 ·
`ADR-0011` Folgepflicht 4 → HIGH-3, MEDIUM-3 · `AGENTS.md` §3.6 → HIGH-2, HIGH-5, MEDIUM-4.

**Muster:** Von den sieben HIGH sind **fünf** Aussagen, die an ihrer Quelle nicht halten
(HIGH-2, HIGH-3, HIGH-5, HIGH-6, HIGH-7) — die aus den ADR-Runden bekannte Klasse
„behauptete, aber nicht gemessene Sensor-/Abdeckungs-Lage" ist im Implementierungs-Schritt
**wiedergekehrt**, jetzt an Code-Kommentaren, `MR-018` und der Commit-Message statt an
ADR-Prosa. Das ist die dritte Wiederholung derselben Klasse und damit nach dem Reviewer-Skill
ein **Steering-Loop-Signal**: der Guide, der zu jeder Zusage die rot färbende Mutation verlangt,
greift bei Zusagen, deren Gegenbeispiel der Autor **selbst formuliert** — die drei falschen
Zusagen hier (107 nimmt die Klemme, `wc -l` zeigt Lücken, der Task-Test misst den fail-closed
Default) sind je durch **ein** Gegenbeispiel widerlegbar, das nie gefahren wurde.

**Gegenläufig, und es soll benannt sein:** die Kern-Konstruktion aus Festlegung 6 — kein stdout,
Exit-Code hart geklemmt — hält auf **jedem** Pfad, den ich zerstören konnte, einschließlich
komplett entzogener Werkzeugkette. Der awk-Scanner ist gegen Desynchronisation sauber gebaut.
Die Ablage-Eigenschaften (Modus, Strom-Trennung, gitignorierter Default) sind live belegt. Die
gemeldeten Lecks sitzen an den **Rändern** des Schemas, nicht in seiner Mitte.

---

## Verdikt

**BLOCKIEREND — nicht konform.**

Sieben HIGH, davon vier direkte Abweichungen von einer **Accepted und damit immutablen** ADR
(HIGH-1, HIGH-3, HIGH-4, HIGH-6) und drei §3.6-Verstöße im Sicherheits- bzw. Sensorpfad
(HIGH-2, HIGH-5, HIGH-7). Nach dem Reviewer-Skill blockieren HIGH und MEDIUM typischerweise;
hier gibt es keinen Grund, davon abzuweichen.

**Der schwerste Punkt ist HIGH-1 zusammen mit HIGH-2:** das geschlossene Schema ist auf der
falschen Achse geschlossen. Der Emitter fragt „heißt das Feld `command`?" statt „steht dieses
Werkzeug in der Tabelle?" — und der Wächter, der das auffangen sollte, prüft eine Payload, an
der beide Achsen dasselbe Ergebnis liefern. `ADR-0011` hat genau diesen Fehler in Runde 5
bereits einmal korrigiert (*„fail-closed Default auf den Werkzeug-Namen statt auf Gattungen —
dort gingen Argumente durch"*); die Implementierung stellt ihn wieder her. Zusammen mit HIGH-7
(eine Umgebungs-Zuweisung als vermeintliches Programm-Token) ist die zentrale Sicherheits-Zusage
der ADR — *„Damit wandert kein Byte fremden Inhalts ins Log"* — an zwei belegten Payload-Formen
falsch, und die Commit-Message führt sie als gemessen.

**Der zweitschwerste ist HIGH-3:** Folgepflicht 4 ist der einzige Mechanismus, mit dem
fail-open nicht zu einem stillen Log wird. Eine aus `wc -l` abgeleitete Nummer kann per
Konstruktion keine Lücke zeigen — dieselbe Sorte „per Konstruktion wahre Zusage", wegen der
Runde 1 die Working-Tree-Hash-Fitness-Function gestrichen hat. Der Mechanismus ist damit
Dekoration, und `MR-018` verkauft ihn als Sichtbarkeit für den Leser.

**Nicht Gegenstand dieses Reviews** (Modul 11): ob die DoD-Punkte abgehakt sind und ob die
Gate-Läufe der Commit-Message vollständig reproduzieren. Die von mir nachgemessenen Zahlen
stehen in den Negativbefunden und halten durchweg — die Befunde oben betreffen **nicht** die
Ehrlichkeit der Zahlen, sondern das, was die grünen Zahlen abdecken.
