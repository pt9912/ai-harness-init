# Code-Review (Modul 10) — slice-060, Auflösung der drei Verifikations-Befunde (`dcee2f3`)

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 10) — frischer Kontext, weder Autor des Codes noch eines Vorgänger-Reports |
| **Datum** | 2026-07-31 |
| **Prüfgegenstand** | Commit `dcee2f3` (ungepusht), sechs Dateien: `.claude/hooks/pretooluse-agent-guard.sh` · `test/agent-guard.bats` · `test/mutations/139-agentguard-typ-failopen.sh` (neu) · `harness/conventions.md` (`MR-018`) · `docs/plan/planning/in-progress/slice-060-rollen-achse.md` · `docs/reviews/2026-07-31-slice-060-dod3-verify.md` |
| **Slice-Plan** | `docs/plan/planning/in-progress/slice-060-rollen-achse.md` — DoD (1) letzte Zeile, DoD (3), §3-Dateitabelle |
| **`LH-*`** | `LH-QA-03` (kein node/jq im Guard-Pfad), `LH-QA-01` (kein Gate über leerem Prüfbereich) |
| **ADRs** | `ADR-0011` (Accepted) Festlegung 1 · `ADR-0004` (Guard ist Stolperdraht, keine Sandbox) · `ADR-0003` (Docker-only) · `ADR-0012` (Proposed, nur berührt) |
| **Hard Rules** | `AGENTS.md` §3.1, §3.2, §3.6 |
| **Vorherige Findings am gleichen Modul** | `docs/reviews/2026-07-31-slice-060-dod3-verify.md` (V-1…V-6, Urteil *nicht bestätigt*) · `docs/reviews/2026-07-31-slice-060-dod3-review-runde-2.md` (M-1/M-2/L-1/L-2) · `docs/reviews/2026-07-30-slice-060-v1-review-runde-2.md` · `docs/reviews/2026-07-30-slice-060-dod2-review-runde-2.md` |
| **Gefahrene Sensoren** | Mutations-Einzelläufe 139 · 117 · 118 · 119 gegen eine isolierte Kopie außerhalb des Repos (Grün-Vorlauf `make test-bats` 150/0), Fall 139 zusätzlich über den kanonischen `run_case`-Pfad des gesourcten `harness/tools/mutate.sh` · Guard direkt gegen vier Payload-Formen · Extraktor direkt gegen vier Payload-Formen · Eigen-Auswertung des Span-Bestands (`.harness/state/spans/`, 47 `Agent`-Spans, 36 Unterströme) · Eigen-Auszählung der `settings.json`-Berührungen und der Token-Treffer |
| **Nicht gefahren** | `make mutate` als Vollauf (Nutzer-Ausschluss, Host-Speicher) — Einordnung: CI auf `65e3b1c` meldete `mutate: 134 ok, 0 Befund(e)`, Fall 139 war darin **nicht** enthalten; ich habe ihn einzeln nachgeholt |
| **DoD (1)/(2)** | nicht erneut aufgemacht — der Diff berührt sie nur an den drei Verifikations-Befunden |

---

## Findings

### MEDIUM-1 — Die Ersatz-Zahl für V-6 ist selbst nicht abgezählt: es sind **fünf** Artefakte, nicht vier

- **kategorie:** MEDIUM
- **quelle:** `MR-018`; `AGENTS.md` §3.6
- **pfad:** `harness/conventions.md:1236-1243`
- **befund:** Die Zeile sagt *„Über `test/**`, `Makefile`, `harness/tools/*.sh` und die Go-Tests berühren die `settings.json` **vier** Artefakte in **drei** Dateien"* und legt die Kategorie *„eine Prüfung ihres bloßen Vorhandenseins"* als **eine** an. Über denselben selbst deklarierten Umfang nachgezählt gibt es davon **zwei**: neben `internal/emit/enforce_test.go:37` (`TestEnforce_EmitsAllMechanicFiles`) prüft `harness/tools/smoke.sh:75-82` denselben Pfad `.claude/settings.json` im emittierten Ziel auf bloßes Vorhandensein (`[ ! -f "$tmprepo/$rel" ]`, Fehlertext *„Durchsetzungsschicht unvollstaendig"*), ohne den Inhalt anzusehen — exakt die Kategorie, die der Text als einmalig führt. Damit sind es unter dem Verb *„die Datei berühren"* **fünf** Artefakte in drei Dateien; die Zahl *drei* unter *„die Verdrahtung prüfen"* stimmt. Die Vier ist wörtlich aus `docs/reviews/2026-07-31-slice-060-dod3-verify.md:207-214` übernommen, wo dieselbe Fundstelle fehlt — eine weitergegebene fremde Zahl, nicht eine nachgezählte. **Was dadurch nicht falsch wird:** die tragende Aussage *„für die Verdrahtung dieses Repos prüft keines etwas"* hält; `harness/tools/smoke.sh:75-82` gilt ebenfalls dem **emittierten** Ziel (`$tmprepo`).
- **verifizierbar:** nein — `comment-claims` deckt kein Markdown, `d-check` prüft keine Sätze. Nachzählbar allein über den im Text selbst benannten Umfang: `grep -rln 'settings\.json' test/ harness/tools/*.sh` plus alle `*_test.go` liefert drei Dateien mit fünf Prüfstellen. Der Befund `V-6` aus der Verifikation ist damit nicht aufgelöst, sondern mit einer zweiten uncounted Zahl beantwortet.

### MEDIUM-2 — „Was es entschiede" nennt eine Sonde, die die offene Frage in keinem der beiden Zweige entscheidet

- **kategorie:** MEDIUM
- **quelle:** `MR-018`; `AGENTS.md` §3.6 (Zusage nicht breiter als ihr Prüfbereich)
- **pfad:** `harness/conventions.md:1254-1263`
- **befund:** Der neue Prüfschritt (c) stellt die offene Frage als *„Welche Aufrufform das war, ist aus dem Repo nicht entscheidbar"* und sagt dann zu: *„**Was es entschiede:** eine Sonde auf die **Schlüsselnamen** von `tool_input` im `Agent`-Zweig des `PreToolUse`-Hooks"*. Die Sonde entscheidet in beiden verbleibenden Zweigen nichts: (i) Feuert der Hook für jenen Aufruf nicht, schreibt die Sonde keine Zeile — dass Schweigen eines Hooks ohne Kontroll-Verdrahtung mehrdeutig ist, hat dieser Slice selbst gemessen und notiert (`docs/plan/planning/in-progress/slice-060-rollen-achse.md:199`, §3 Zeile 8: *„ein stiller Hook wäre sonst mehrdeutig gewesen"*). (ii) Feuert er, so ist die Aufrufform aus dem Bestand bereits ableitbar — derselbe Plan-Eintrag hält fest, dass `PreToolUse` für `Agent` feuert und `tool_input` `subagent_type` und `run_in_background` schon vor dem Lauf trägt; ein Rollen-Typ, den der Guard sieht und nicht ablehnt, kann nach seiner in `test/agent-guard.bats` gemessenen Entscheidungsfunktion nur `run_in_background: false` getragen haben. Offen bleibt dann nicht die Aufrufform, sondern warum eine **Vordergrund**-Antwort keinen der Zähler trug, obwohl die vendored Referenz für `status: "completed"` `usage`, `totalTokens`, `totalDurationMs` und `totalToolUseCount` führt (`docs/user/claude-hooks-referenz.md:1564-1574`) — und daran rührt eine `tool_input`-Sonde nicht.
- **verifizierbar:** nein direkt; die Prämissen sind belegt (`docs/plan/planning/in-progress/slice-060-rollen-achse.md:199`; `test/agent-guard.bats:132-178` in `make test-bats`; `docs/user/claude-hooks-referenz.md:1564-1576`). Der Befund fällt auf, sobald jemand die genannte Sonde baut und ihr Ergebnis — Zeile oder Schweigen — der Frage zuordnen soll.

### LOW-1 — Der Kopf des Guards sagt eine unbedingte fail-closed-Politik zu, die für einen der fünf aufgezählten Eingänge nicht gilt

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.6; `MR-018`
- **pfad:** `.claude/hooks/pretooluse-agent-guard.sh:13-16`
- **befund:** *„JEDER unlesbare Eingang endet fail-closed (verweigern): fehlendes awk, fehlender Extraktor, Parse-Zweifel, fehlender Typ, fehlender Schalter."* Für *fehlender Schalter* gilt das nur bei Rollen-Typen: `:94` (`[ -f "$agents_dir/$stype.md" ] || exit 0`) lässt `general-purpose`, `Explore` und jeden Typ ohne Datei in `.claude/agents/` mit fehlendem Schalter durch — belegt von `test/agent-guard.bats:149-162` (drei PASS-Zusagen). Die vier übrigen Posten sind unbedingt; der Kommentar an der Stelle selbst (`:97-99`) ist korrekt auf Rollen eingeschränkt, der Kopf ist es nicht.
- **verifizierbar:** ja — `make test-bats`: die PASS-Fälle `guard: general-purpose im Hintergrund -> PASS` und `guard: erfundener Typ im Hintergrund -> PASS` sind grün und wären unter einer wörtlich umgesetzten Kopf-Zusage rot.

### LOW-2 — Der Ablehnungsgrund des neuen Zweigs nennt eine Abhilfe, die diese Ablehnung nicht aufhebt

- **kategorie:** LOW
- **quelle:** Maintainability; `MR-018` (der Grund erscheint **wörtlich** beim Aufrufer, am 2026-07-29 gemessen)
- **pfad:** `.claude/hooks/pretooluse-agent-guard.sh:89`
- **befund:** Der Text endet mit *„…; ein Rollen-Typ startet mit `run_in_background: false`."* — derselbe Schlusssatz wie im Parse-Zweifel-Zweig (`:76`). In diesem Zweig ist er wirkungslos: der Aufruf wurde nicht wegen der Betriebsart abgelehnt, sondern weil kein Typ lesbar war; der Schalter steht im rot gesehenen bats-Fall bereits auf `false` (`test/agent-guard.bats:176`). Failure-Szenario: der Aufrufer — Mensch oder Modell — liest die einzige handlungsförmige Zeile der Meldung, setzt `run_in_background: false` und wird erneut abgelehnt, ohne dass die Meldung sich ändert.
- **verifizierbar:** nein durch ein Gate; ablesbar am Ablehnungstext, den `test/agent-guard.bats:175-178` auslöst.

### LOW-3 — Fall 139 begründet das Grünbleiben der Nachbar-Fälle mit einer Eigenschaft, die einer von ihnen nicht hat

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.6 (Kommentar beschreibt den Code)
- **pfad:** `test/mutations/139-agentguard-typ-failopen.sh:17-19`
- **befund:** *„Die uebrigen guard-Faelle bleiben gruen: sie tragen alle einen Typ…"*. `test/agent-guard.bats:164-167` (`guard: kaputte Eingabe -> DENY (fail-closed)`, Payload `nicht mal JSON`) trägt **keinen** Typ; er bleibt grün, weil der Extraktor für diese Payload mit Status 3 endet und `:75-76` zwölf Zeilen früher verweigert — selbst nachgemessen (`awk -f harness/tools/extract-agent-call.awk` auf dieser Payload: `rc=3`). Die Schlussfolgerung des Kommentars ist richtig (ich habe genau **eine** `not ok`-Zeile gezählt), seine Begründung ist es für einen der Fälle nicht.
- **verifizierbar:** ja, indirekt — der Einzellauf von Fall 139 zeigt genau eine `not ok`-Zeile; welche Fälle aus welchem Grund grün bleiben, prüft kein Sensor (`comment-claims` deckt `test/` nicht, `AGENTS.md` §4).

### LOW-4 — Der Kopf von Abweichung 5 ist enger als die Abweichung, die dieser Commit dort verbreitert hat

- **kategorie:** LOW
- **quelle:** `MR-018`; `ADR-0011` Festlegung 1 Punkt 5
- **pfad:** `harness/conventions.md:1185` gegen `:1266-1269`
- **befund:** Der Kopf lautet unverändert *„Ein **Hintergrund**-Lauf trägt keine Verbrauchs-Achse — der Guard verkleinert die Lücke, er schließt sie nicht"*. Der Abweichungs-Satz ist in diesem Commit von *„ein `Agent`-Span aus einem Hintergrund-Lauf"* auf *„ein `Agent`-Span **ohne Zähler**"* verbreitert worden, ausdrücklich mit dem Zusatz *„dass es **nicht nur** dort eintritt, steht in (c)"*. Wer die sechs Abweichungen über ihre Köpfe überfliegt — die Liste ist als Übersicht gebaut (`:1051`) —, bekommt die schmalere Fassung.
- **verifizierbar:** nein — Prosa in `harness/conventions.md`, außerhalb jedes Gates.

### LOW-5 — Die Kurzfassung der Guard-Grenzen im selben Satz wie die neue fail-closed-Politik lässt offen, worauf „greift" sich bezieht

- **kategorie:** LOW
- **quelle:** `MR-018`
- **pfad:** `harness/conventions.md:1006-1010`
- **befund:** Derselbe Satz führt erst *„fail-closed-Politik bei fehlendem Schalter **und fehlendem Typ**"* und schließt dann *„kurz: er greift **nur** für Typen mit einer Datei in `.claude/agents/`, er sieht nur den Start, und er kann fehlen oder abgeschaltet sein"*. Als Aussage über die Vordergrund-Erzwingung ist das *nur* richtig; als Aussage über den Guard (das Subjekt der drei Glieder — das zweite und dritte Glied sind Aussagen über den Guard, nicht über Bedingung 2) ist es seit diesem Commit falsch: `:89` verweigert einen Agenten-Aufruf **ohne** jeden Typ, also ohne jede Datei in `.claude/agents/`. Failure-Szenario: wer eine abgelehnte `Agent`-Anfrage eines Nicht-Rollen-Typs diagnostiziert, schließt anhand dieser Zeile den Agent-Guard als Ursache aus.
- **verifizierbar:** nein — Prosa; gegenzuprüfen an `.claude/hooks/pretooluse-agent-guard.sh:89` und `test/agent-guard.bats:175-178`.

### INFO-1 — Der neu geschaffene Über-Blockier-Modus steht in keiner der drei Grenz-Positionen

- **kategorie:** INFO
- **quelle:** `MR-018`, Abweichung 5 Prüfschritt 3
- **pfad:** `harness/conventions.md:1214-1264`
- **befund:** Die Aufzählung *„Was er nicht deckt"* führt nach diesem Commit (a) Typen ohne Rollen-Datei, (b) die ungeprüfte Verdrahtung, (c) Start statt Ausgang — alle drei sind **Unter**-Deckung. Der Commit schafft zugleich eine **Über**-Deckung: gibt es eine reale `Agent`-Aufrufform ohne `subagent_type`, wird sie ab jetzt abgelehnt. Die Grundlage dafür ist geprüft und trägt — das dokumentierte Eingabe-Schema führt `subagent_type` ohne den Zusatz *Optional*, den es bei `model` ausdrücklich setzt (`docs/user/claude-hooks-referenz.md:1558-1561`), und `"matcher": "Agent"` liegt nach `docs/user/claude-hooks-referenz.md:194-200` auf dem **Exact-Match**-Pfad, trifft also keinen Fremd-Werkzeugnamen. Der Fehlermodus wäre außerdem **laut**: `emit_deny` schreibt `permissionDecisionReason`, und dass dieser Text wörtlich beim Aufrufer ankommt, ist in `MR-018` als gemessen geführt. Nicht geschrieben steht, dass es **nicht gemessen** ist, ob eine solche Payload real vorkommt — der Guard-Kopf formuliert es als *„keine bekannte Aufrufform"* (`.claude/hooks/pretooluse-agent-guard.sh:83-88`), was die Nicht-Messung andeutet, aber nicht ausspricht.
- **verifizierbar:** nein — es gibt kein Artefakt im Repo, an dem eine reale `PreToolUse`-Payload nachvollziehbar wäre; das sagt `MR-018:1254-1256` selbst.

---

## Negativbefunde (geprüft, ohne Befund)

1. **Der geschlossene fail-open-Zweig.** `.claude/hooks/pretooluse-agent-guard.sh:89` ruft `emit_deny` und beendet mit 0; die Ausgabeform ist `hookSpecificOutput.permissionDecision` wie in den übrigen Deny-Zweigen. Direkt gegen vier Payload-Formen gefahren; der Extraktor liefert für `{"tool_name":"Agent","tool_input":{"prompt":"x","run_in_background":false}}` `rc=0` mit `false`/`ABSENT`, die Ablehnung stammt also aus dem neuen Zweig und nicht aus dem Parse-Zweifel. Kein Befund.
2. **Der neue Zahn hat Zähne — selbst ausgezählt über *alle* Fehlschlag-Zeilen.** Isolierte Kopie außerhalb des Repos, Grün-Vorlauf `make test-bats` = **150 ok / 0 not ok**. Nach `test/mutations/139-agentguard-typ-failopen.sh`: **genau eine** `not ok`-Zeile, `not ok 19 guard: Agent-Aufruf ohne Subagent-Typ -> DENY (fail-closed)`, 149 ok. Der Fall zusätzlich über den kanonischen Pfad gefahren (gesourctes `harness/tools/mutate.sh`, `run_case`): `mutate: ok 139-agentguard-typ-failopen -> … rot`. Der `sed`-Anker stellt exakt die Vorgänger-Zeile `[ "$stype" = "ABSENT" ] && exit 0` wieder her (byte-gleich zu `dcee2f3^`). Kein Befund.
3. **Die drei Nachbar-Fälle beißen weiter, und keiner beißt aus mehreren Gründen unbemerkt.** 117 → **vier** `not ok` (15, 16, 17, 23) — genau die vier, die der Fall-Kopf selbst ankündigt; 118 → **zwei** (22, 23), ebenfalls im Kopf angekündigt; 119 → **eine** (13). Kein Fall wird durch den neuen Zweig zusätzlich rot. Kein Befund.
4. **Host-Baum unberührt.** `sha256sum` von `.claude/hooks/pretooluse-agent-guard.sh` und `test/agent-guard.bats` vor und nach allen fünf Mutationsläufen identisch; mutiert wurde ausschließlich in der Kopie außerhalb des Repos. Kein Befund.
5. **Die Teil-Widerlegung der Verifikations-Prämisse trägt, und die Auflösung folgt ihr.** `docs/user/claude-hooks-referenz.md:1576` sagt wörtlich, dass das Werkzeug für Hintergrund-Subagenten **sofort** nach dem Start zurückgibt; der Eltern-Span trägt `duration_ms: 640572`. Der neue Text `harness/conventions.md:1254-1260` zieht daraus **nur** die Ausschluss-Aussage („ein Hintergrund-Start im Sinne des Schalters passt nicht zu der Dauer") und **keine** zweite positive Erklärung; die Gegen-Beobachtung — der Wert-Satz des Spans ist genau die Hintergrund-Gestalt — steht zwei Sätze davor im selben Absatz (`:1248-1252`), wird also nicht unterschlagen. Beides selbst nachgemessen. Kein Befund an dieser Stelle (die verbleibende Lücke ist MEDIUM-2 und betrifft nur den Satz über die Sonde).
6. **Die zwei eingeschränkten Zusagen sind so breit wie ihr Wächter.** `harness/conventions.md:995-998` sagt jetzt zu, was `test/agent-guard.bats` und die Fälle 117/118/119/139 messen: die **Entscheidungsfunktion** an einer vorgelegten Aufrufform. `:1200` (*„Vermeidbar? Für die Aufrufform, die der Guard sieht, ja — und nur für sie"*) ebenso. Die frühere Formulierung *„Bedingung 2 ist für Rollen-Typen erzwungen"* / *„gelöst, nicht erklärt"* kommt im ganzen Repo nicht mehr vor (`grep`, außerhalb `docs/reviews/`). Kein Befund.
7. **Die Mechanik der zwei Dauern ist an beiden Stellen korrekt nachgezogen und im Repo widerspruchsfrei.** *„Der Hook feuert beim Start"* existiert außerhalb der Review-Ablage nicht mehr. Die Ersatz-Aussage ist zweifach belegt: `.claude/settings.json` hängt den Emitter an `PostToolUse`/`PostToolUseFailure`, und `docs/user/claude-hooks-referenz.md:1821` definiert `duration_ms` als *„Tool-Ausführungszeit"*. Selbst nachgemessen über alle 47 `Agent`-Spans: **25 von 25** Spans mit beiden Werten zeigen `duration_ms` **über** `total_duration_ms` (Differenz 1.450–13.324 ms); **null** Spans tragen ein `duration_ms` unter 1.000 ms neben einem `total_duration_ms`. Die Formulierung in `harness/conventions.md:872` verzichtet auf die Zahl und benennt das Gegenbeispiel (*„ein Span, in dem `duration_ms` **unter** `total_duration_ms` liegt, wäre der Befund"*) — §3.6-konforme Form. Kein Befund.
8. **Die gealterte Zahl `:1298` ist entfernt, nicht ersetzt — und die tragende Aussage hält.** Der Satz sucht jetzt statt zu zitieren (*„und **jede** Treffer-Datei gelesen"*, `harness/conventions.md:1344-1350`) und begründet den Verzicht. Selbst nachgesucht: **neun** Treffer-Dateien (acht unter `open/`/`next/`/`in-progress/` plus `docs/plan/planning/welle-09-modul-15-konformitaet.md`) — die alte Fünf wäre heute falsch. Jede der neun gelesen: keine führt die Bedingung *„eine Quelle im Repo, die Haupt-Kontext-Token trägt"*; `docs/plan/planning/open/slice-068-rollen-arbeit-laeuft-als-rolle.md:88-98` hat den Punkt ausdrücklich abgegeben. Kein Befund.
9. **Die Plan-Zeile `test/` ist korrigiert und die neue Fassung stimmt.** *„Neu unter `test/` sind zwei Dinge, nicht eines"* — nachgezählt über alle slice-060-Commits: unter `test/` sind genau `test/agent-guard.bats` (angelegt in `dd15b02`) und Dateien unter `test/mutations/` hinzugekommen, nichts sonst. Kein Befund.
10. **Die §3-Zeile 6 des Plans.** Die neue Fassung (`docs/plan/planning/in-progress/slice-060-rollen-achse.md:197`) deckt sich mit meiner eigenen Messung am Bestand (kein `duration_ms` im Millisekunden-Bereich neben einem `totalDurationMs`) und mit der vendored Referenz. Kein Befund.
11. **Zuschreibung ohne Bindung.** Jeder in diesem Diff genannte Sensor existiert und beißt: `test/agent-guard.bats "guard: Agent-Aufruf ohne Subagent-Typ -> DENY (fail-closed)"` (rot gesehen), `test/mutations/139-agentguard-typ-failopen.sh` (rot gesehen), 117/118/119 (rot gesehen), `test/mutations/32-enforce-settings-wires-guard.sh` (`# expect: TestEnforce_SettingsWiresBothHooks` — gelesen, deckt sich mit der Zuschreibung in `harness/conventions.md:1241-1242`). Kein Befund.
12. **`AGENTS.md` §3.2 (Lint-Suppression).** Kein `# shellcheck disable` und kein `//nolint` im Diff. Kein Befund.
13. **`LH-QA-03` / `ADR-0004`.** Der neue Zweig bleibt reines bash; kein `node`/`jq`/`python` kommt hinzu. Kein Befund.
14. **`AGENTS.md` §3.5 (Gate-Lockerung).** Der Diff verschärft (ein Pass-Pfad wird zu einem Deny-Pfad, ein Fall kommt hinzu); keine Schwellensenkung, also kein ADR nötig. Kein Befund.
15. **`AGENTS.md` §3.1 (halluzinierte Gates).** Kein neuer Gate-Name, kein neues Target; Fall 139 fällt in den bestehenden `make mutate`-Bestand. Kein Befund.
16. **`AGENTS.md` §3.3 (`git mv` + Inhaltsänderung).** Kein Rename im Commit. Kein Befund.
17. **Der Mit-Commit des Verifikations-Berichts.** `docs/reviews/2026-07-31-slice-060-dod3-verify.md` ist ein Prozess-Artefakt und liegt außerhalb der §3-Dateitabelle; anders als bei `111fcdd` liegt hier der Bericht mit **seiner Auflösung** in einem Commit, was die Nachvollziehbarkeit der Reihenfolge erschwert, aber keiner Regel dieses Repos widerspricht. Kein Befund.
18. **DoD (1) und (2).** Nicht erneut aufgemacht; der Diff berührt sie nur über die drei Verifikations-Befunde. Kein Befund.

---

## Die Streitfrage `:1204` — wer recht hat

**Der Implementer.** Die beanstandete Zeile stand in Prüfschritt 3 **(a)**, und (a) hat als Subjekt ausdrücklich *„ein Typ **ohne** Datei in `.claude/agents/`"*; der Satz zwei Zeilen davor lautet *„In **ihre** `Agent`-Spans gelangt von den neun Werten höchstens einer"*. Der Span, den der Verifikations-Bericht als Bestätigung anführt (`seq 469`, `2026-07-31T14:22:54Z`), stammt von `architect` — selbst nachgeprüft: Startzeitpunkt `14:22:54Z` minus `640.572 s` = `14:12:13Z`, der Unterstrom `…-ad048039fd60fec5f.jsonl` beginnt `14:12:16Z` und trägt `agent_type: "architect"` in **37 von 37** Zeilen, und `.claude/agents/architect.md` existiert. Ein Rollen-Typ ist damit kein Beleg für eine Aussage über Nicht-Rollen-Typen; er zeigt die **Gestalt** (ein `Agent`-Span mit genau `model_version` und keinem der acht), nicht den Fall. Die Feststellung *„und ein solcher liegt nicht vor"* (`harness/conventions.md:1225`) habe ich ebenfalls nachgemessen: alle Unterströme mit `agent_type: "general-purpose"` liegen am 2026-07-29, also **vor** dem Landen der Positiv-Liste (`2026-07-30T07:39:37Z`); seither gibt es keinen `Agent`-Span eines Typs ohne Rollen-Datei. Die neue Fassung `:1222-1232` ist damit korrekt, und sie behebt zugleich die Unschärfe, die den Fehl-Schluss ermöglicht hat: die alte Zeile ließ das Subjekt *„ohne Datei in `.claude/agents/`"* an der entscheidenden Stelle weg.

---

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 5 |
| INFO | 1 |
| **Summe** | **8** |

Wiederkehrende Klasse (Steering-Loop-Signal): *„Zahl behauptet statt abgezählt"* tritt in MEDIUM-1 in ihrer Weitergabe-Variante auf — die Vier stammt aus dem Verifikations-Bericht und wurde nicht nachgezählt. *„Aussage breiter als ihr Prüfbereich"* tritt in MEDIUM-2, LOW-1, LOW-3 und LOW-5 auf, also viermal in einem Commit, der genau diese Klasse auflösen sollte. Beides gehört in die Closure-Notiz, nicht nur in diesen Report.

---

## Verdikt

**NICHT KONFORM.**

Zwei MEDIUM blockieren nach der Kategorien-Semantik des Reviewer-Skills. Die drei Verifikations-Befunde sind der Substanz nach aufgelöst — der fail-open-Zweig ist geschlossen und mit einem Zahn **und** einem Dauer-Sensor gebunden (beide von mir rot gesehen, mit genau einer Fehlschlag-Zeile), die zwei Erzwingungs-Zusagen reichen jetzt so weit wie die gemessene Entscheidungsfunktion, und die falsche Dauer-Mechanik ist an allen drei Fundstellen ersetzt statt kommentiert. Blockierend ist, was mit der Auflösung neu entstanden ist: eine Zahl, die als Auflösung von `V-6` auftritt und selbst nicht abgezählt wurde (MEDIUM-1), und eine Sonde, deren zugesagte Entscheidungskraft in beiden offenen Zweigen nicht besteht (MEDIUM-2). Beide liegen in `harness/conventions.md`, das außerhalb jedes Gates liegt, das Aussagen prüft — sie fallen nur beim Lesen auf und werden mit der Closure eingefroren.
