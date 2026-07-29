# Review-Report: slice-060 + slice-066 (Plan, Runde 4 — DELTA) — 2026-07-29

**Review-Art:** **Plan, verengt auf das Delta.** Geprüft wird (a) ob die Korrekturen der Runde 3
halten und (b) was im Delta neu ist und noch nie gereviewt wurde. **Nicht** geprüft: der Plan zum
vierten Mal von vorn; Code (nur gelesen, soweit er eine Plan-Aussage belegt oder widerlegt);
DoD-Abhakung (Modul 11, getrennter Kontext).

**Gegenstand:**

- `docs/plan/planning/open/slice-060-rollen-achse.md` (Stand `c0243e4`)
- `docs/plan/planning/open/slice-066-telemetrie-auswertung.md` (Stand `b093502`)
- die Antwort-Commits `b093502` (die 17 Runde-3-Befunde) und `c0243e4` (der selbst gefundene
  Folgefehler in der eigenen F-17-Korrektur)
- mitbetroffen: `harness/conventions.md` ([`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids), [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)) und
  `docs/plan/planning/welle-09-modul-15-konformitaet.md` §4

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-29

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- der Report der Runde 3 (`docs/reviews/2026-07-29-slice-060-066-plan-review-runde-3.md`,
  1 HIGH · 9 MEDIUM · 7 LOW · 2 INFO) — die Befund-Liste, gegen die die Antwort gemessen wird
- Plan-Artefakte: die zwei Slice-Dateien, `docs/plan/planning/welle-09-modul-15-konformitaet.md`
  (höherrangig), der geschlossene Vorgänger
  `docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md`
- Regelwerk (Baseline v3.5.2, vendored): `modul-05-planning-harness.md` §Ziel-Form: Slice,
  `modul-10-review-harness.md`, `modul-15-observability.md` §Token-Attributions-Regeln und
  §Cache-Counter-Regeln
- ADR: [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) (**Accepted**, immutabel),
  [`ADR-0003`](../plan/adr/0003-go-native-binaries.md)
- Adaptionen: [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage), [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids), [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
- Hard Rules: [`AGENTS.md`](../../AGENTS.md) §3, besonders §3.1/§3.4/§3.5/§3.6
- Belege aus dem Code/Repo: `.claude/settings.json`, `.claude/hooks/pretooluse-command-guard.sh`,
  `harness/tools/extract-command.awk` (referenziert), `internal/span/emit.go` (`references()`,
  `roleFromAgentType`), `test/guard.bats`, `test/mutations/108`, `test/mutations/115`,
  `.d-check.yml`
- Werkzeug-Doku (extern, **nicht** repo-autoritativ, committet vendored):
  `docs/user/claude-hooks-referenz.md`
- **Keine Gate-Läufe in dieser Sitzung** (Ressourcen-Schranke, wie in den Vorrunden). Jeder Befund
  ist an einer **lesbaren Quelle** belegt; die `verifizierbar`-Zeile nennt, was ein Lauf zusätzlich
  zeigen würde.

**Vorab, weil es die Runde trägt.** Die Antwort ist substanziell: 13 der 17 Befunde sind
geschlossen, mehrere davon gut — der Grenz-Zahn in slice-060 DoD (2) trifft die Eigenschaft
wirklich (nicht nur einen fünften Namen), die ADR-Umdeutung ist verankert, die
`.d-check.yml`-Ausnahme auch, und `c0243e4` ist ein selbst gefundener, korrekt diagnostizierter
Mechanik-Fehler in der eigenen Korrektur. Die Befunde unten betreffen (a) **eine Korrektur, die
nur in einem der zwei Slices angekommen ist** und dadurch einen Widerspruch **erzeugt** hat, wo
vorher Einigkeit herrschte, (b) **eine falsche Aussage über eine immutable ADR**, mit der ein
korrekter Runde-3-Befund zurückgewiesen wurde, und (c) den **neuen Guard**, dessen tragende
Prämissen im Plan weder zitiert noch gemessen sind.

---

## Findings

### F-1 — Die zurückgezogene Sensor-Verneinung steht unverändert in slice-066 und widerspricht dort slice-060 DoD (1) wörtlich

- `kategorie`: **HIGH**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · [`AGENTS.md`](../../AGENTS.md) §2 (Source
  Precedence — zwei Slices derselben Welle dürfen sich nicht widersprechen) ·
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) §Geschichte 2026-07-28 (Runde 6:
  falsche Sensor-**Verneinung** als HIGH) · Memory-Regel *„grep ist keine Messung"*
- `pfad`: `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:56` gegen
  `docs/plan/planning/open/slice-060-rollen-achse.md:65-76` und `:188-195`
- `befund`: Der Runde-3-HIGH betraf den Satz *„Und sie hat keinen Sensor."* In slice-060 ist er
  ersetzt (§6 nennt die Fehl-Behauptung jetzt selbst beim Namen, DoD (1) trägt den Guard-Entwurf).
  In slice-066 steht er wörtlich weiter: *„Die Vordergrund-Konvention aus slice-060 hat **keinen
  Sensor** — ein Hintergrund-Start fehlt lautlos"*. Der Commit `b093502` nennt in seiner Message
  ausdrücklich den **anderen** Grund, aus dem die Abdeckungszahl bleibt (*„ein Guard kann fehlen,
  abgeschaltet oder umgangen sein"*) — dieser Grund steht in slice-060 §6 als eigener Punkt, aber
  **nicht** in slice-066, wo er hingehört hätte. Die Halb-Anwendung ist damit nicht nur ein
  Rest: vorher trugen beide Slices dieselbe (falsche) Aussage, jetzt trägt einer die Korrektur
  und der andere die Verneinung. Die Welle enthält einen direkten Widerspruch, den es vor der
  Korrektur nicht gab.
- `failure-szenario`: Der Implementer von slice-066 liest seine eigene DoD (1), findet *„hat keinen
  Sensor"*, schließt daraus, dass slice-060 die Bedingung nicht durchsetzt, und dimensioniert die
  Abdeckungszahl als **einzige** Absicherung. Fällt der Guard aus DoD (1) beim Schneiden weg oder
  wird er zurückgestellt, merkt es niemand — die einzige Stelle, die den Guard verlangt, ist der
  andere Slice, und der Auswerter-Slice sagt schriftlich, es gebe ihn nicht.
- `verifizierbar`: ja, ohne Gate —
  `sed -n '55,58p' docs/plan/planning/open/slice-066-telemetrie-auswertung.md` gegen
  `sed -n '65,76p;188,198p' docs/plan/planning/open/slice-060-rollen-achse.md`. `make gates` zeigt
  es nicht: beides sind Plan-Absätze.

### F-2 — Der korrekte Runde-3-Verweis auf [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 4 wurde mit einer falschen Aussage über die ADR zurückgewiesen („die Festlegung hat drei Punkte") — sie hat fünf, und derselbe Slice zitiert Punkt 5

- `kategorie`: **HIGH**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (*„Eine Zusage — Doc-Kommentar, Test-Name,
  DoD-Punkt, **Commit-Message** — ist erst fertig, wenn benannt ist, was passieren müsste, damit
  sie bricht"*) · [`AGENTS.md`](../../AGENTS.md) §3.4 (die ADR ist immutabel und damit die
  verlässliche Fundstelle) · Memory-Regel *„Keine fabrizierten Digests"* ·
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:70`, `:73`, `:75`, `:82`, `:93` (die
  Listenmarken 1–5) · `docs/reviews/2026-07-29-slice-060-066-plan-review-runde-3.md:165-168`
- `pfad`: Commit-Message `b093502` (Absatz *„Frage C fuehrte die falschen Reste"*) gegen
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:82-92` und
  `docs/plan/planning/open/slice-060-rollen-achse.md:105-108`
- `befund`: Die Antwort weist die vom Reviewer genannte Fundstelle zurück: *„Der Review verweist
  dafuer auf ‚ADR-0011 Festlegung 1 Punkt 4'; die Festlegung hat drei Punkte. Die Fundstelle ist
  nicht uebernommen."* Festlegung 1 hat **fünf** nummerierte Punkte (`:70`, `:73`, `:75`, `:82`,
  `:93`), und **Punkt 4 ist genau die zitierte Regel**: *„Ableiten schlägt deklarieren … **Die
  Ableitung muss ihre Randfälle mitentscheiden, sonst ist sie keine:** … liegen **mehrere**
  `LH-*`-IDs im Bezug …, trägt der Span sie **alle**"* — samt dem Mehrfach-Beispiel, das der
  Runde-3-Befund zitierte. Der Verweis trug; zurückgewiesen wurde er mit einer ungeprüften
  Aussage über eine **immutable** kanonische Quelle. Die Selbstwiderlegung steht in derselben
  Datei: slice-060 DoD (3) beruft sich auf *„[`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt **5**"* (`:108`) — ein
  Punkt, den es nach der eigenen Behauptung nicht gibt. Der Sachgehalt des Befunds ist
  übernommen (Mehrfach-Treffer und Zustands-Brücke stehen jetzt in Frage C); die **normative
  Verankerung** ist es nicht: dass eine Ableitung ohne entschiedene Randfälle *keine Ableitung
  ist*, ist eine bindende ADR-Festlegung und steht in keinem der zwei Pläne.
- `failure-szenario`: Frage C wird später entschieden. Der Entscheider liest Frage C, findet dort
  vier Reste ohne normativen Rang und behandelt den Mehrfach-Treffer als Komfort-Frage statt als
  Bedingung dafür, dass die Ableitung überhaupt eine ist. Die Rollen-Ableitung geht ohne
  Randfall-Entscheidung in den Code — genau der Fall, den Festlegung 1 Punkt 4 ausschließt, jetzt
  gedeckt durch einen Commit, der die Festlegung für nicht existent erklärt hat. Zweiter,
  schwererer Weg: die Klasse selbst. Dreimal in dieser Slice-Familie wurde eine
  Abwesenheits-/Vollständigkeitsaussage ohne Nachsehen getroffen (Runde-5-HIGH der ADR, Runde-3-HIGH
  dieses Plans, dieser Befund) — nach `.harness/skills/reviewer.md` §Kontext-Eskalation ist die
  dritte Wiederholung ein Steering-Loop-Signal, kein Einzelfall.
- `verifizierbar`: ja, ohne Gate —
  `awk 'NR>=64 && NR<=96 && /^[0-9]\./ {print NR": "$0}' docs/plan/adr/0011-telemetrie-erfassung-policy.md`
  liefert fünf Zeilen; `git log -1 --format=%B b093502 | grep -n "drei Punkte"` liefert die
  Behauptung; `sed -n '105,108p' docs/plan/planning/open/slice-060-rollen-achse.md` liefert die
  Selbstwiderlegung.

### F-3 — Der neue `PreToolUse`-Guard ruht auf zwei Prämissen, die der Plan weder zitiert noch misst; eine davon fehlt im dokumentierten `Agent`-Eingabeschema

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 ·
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  §„Was die Payload sonst noch trägt" (*„**Die Payload ist die Quelle, die Doku ist Herkunft**"* —
  dieselbe Doku hatte `tool_response` schon einmal falsch nahegelegt) ·
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) §Re-Evaluierungs-Trigger 1
  (*„Wenn das Agenten-Werkzeug seine Hook-Oberfläche ändert"* — die Quelle ist **nicht gepinnt**) ·
  `docs/user/claude-hooks-referenz.md:1438` und `:1556-1561`
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:65-76`
- `befund`: DoD (1) verlangt *„ein zweiter Eintrag mit `"matcher": "Agent"`"*. Zwei Prämissen
  tragen das, keine steht im Plan. **(a)** Dass `PreToolUse` bei `Agent` überhaupt feuert, ist
  in der vendored Referenz belegt (`:1438` zählt `Agent` in der Tool-Namen-Liste von `PreToolUse`
  auf) — der Plan nennt diese Zeile nicht und stützt sich stattdessen darauf, dass „der
  Mechanismus in diesem Repo bereits läuft"; er läuft auf `"matcher": "Bash"`
  (`.claude/settings.json:5`), was über `Agent` nichts aussagt. Belegt ist es also, aber **nicht
  im Plan** und **nicht gemessen**. **(b)** `run_in_background` steht **nicht** in der
  dokumentierten `tool_input`-Tabelle des `Agent`-Werkzeugs (`:1556-1561` führt `prompt`,
  `description`, `subagent_type`, `model` — sonst nichts). Der Plan hat es gemessen (§3 Zeile 5),
  und die Messung schlägt die Doku nach der eigenen Regel; genau deshalb gehört die Differenz
  benannt: das Prädikat des Guards ist ein **undokumentiertes** Feld einer ungepinnten
  Oberfläche.
- `failure-szenario`: Eine Werkzeug-Version benennt das Feld um oder lässt es weg. Der Guard
  prüft *„`run_in_background` nicht `false`"* — bei fehlendem Feld ist die Bedingung **wahr**,
  also lehnt er ab **jeden** Rollen-Aufruf ab, auch den korrekt im Vordergrund gestarteten. Der
  Harness blockiert sich an seiner eigenen Rollen-Mechanik, und die Ursache steht in keinem Plan,
  weil die Abhängigkeit nie ausgesprochen wurde. Der umgekehrte Ausgang ist genauso still: liest
  der Guard das Feld an einem anderen Ort, greift er nie und die Zähler fehlen weiter lautlos.
- `verifizierbar`: ja, ohne Gate — `sed -n '1438p;1556,1561p' docs/user/claude-hooks-referenz.md`
  gegen `sed -n '65,76p' docs/plan/planning/open/slice-060-rollen-achse.md`. Eine **Messung** (ein
  echter `Agent`-Aufruf mit verdrahtetem Testhook) würde beide Prämissen entscheiden; der Plan
  hat für die drei vorangegangenen Fragen genau das getan.

### F-4 — Der Zahn zu DoD (1) benennt den Testfall, nicht das Gegenbeispiel — im selben Slice, in dem DoD (2) es vorbildlich tut

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (*„erst fertig, wenn benannt ist, **was passieren
  müsste, damit sie bricht**, und das einmal rot gesehen wurde"*) ·
  `docs/plan/planning/welle-09-modul-15-konformitaet.md:90` (Wert **Sensor** = *„läuft real, mit
  `test/mutations/`-Fall"*) · `test/guard.bats:1-9`, `test/mutations/42-guard-baked-floor.sh`,
  `test/mutations/43-guard-blocked-union.sh` (die etablierte Bauform)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:74-76` gegen `:98-104`
- `befund`: DoD (1) schließt mit *„der Zahn ist ein Rollen-Aufruf im Hintergrund, den der Guard rot
  ablehnt"*. Das ist die **Eingabe eines Positiv-Tests**, nicht das Gegenbeispiel: ein Guard, der
  ablehnt, ist grün, nicht rot. Rot werden muss der **Sensor**, wenn die Prüfung aus dem Guard
  verschwindet — also `test/guard.bats` unter einem `test/mutations/`-Fall, der die
  `run_in_background`-Bedingung entfernt. Genau diese Form steht 25 Zeilen weiter unten in DoD (2)
  ausgeschrieben (*„die Mutation stellt die Erfassung auf ‚alles außer den vier' um"*) — DoD (1)
  bekommt sie nicht. Die Formulierung *„Regel mit Gegenbeispiel"* behauptet damit eine
  Eigenschaft, die der Satz daneben nicht liefert.
- `failure-szenario`: Der Implementer schreibt einen bats-Fall, der einen Hintergrund-Aufruf
  füttert und `"decision": "block"` erwartet. Er ist grün. Ein späterer Handgriff am Guard (etwa
  eine Umstellung auf `subagent_type`-Präfixe) entschärft die Bedingung; der Fall bleibt grün,
  weil er die heutige Implementierung misst. `make mutate` meldet nichts, weil der Wächter nie in
  `test/mutations/` gelistet wurde — *„wer keinen Fall in `test/mutations/` hat, ist unbewacht"*
  ([`AGENTS.md`](../../AGENTS.md) §3.6). Die Welle bucht Block 2 als „Sensor", belegt ist ein Test
  ohne Zahn.
- `verifizierbar`: ja, ohne Gate — `sed -n '74,76p;98,104p' docs/plan/planning/open/slice-060-rollen-achse.md`.
  Nach der Umsetzung zeigt es `make mutate` **nicht**: ein nicht gelisteter Wächter fällt dort
  nicht auf.

### F-5 — Der Guard muss Rollen-Typen von anderen Agenten-Typen unterscheiden; woher er die Liste nimmt, sagt kein Plan — es entstünde die dritte Kopie ohne Kopplung

- `kategorie`: **MEDIUM**
- `quelle`: [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  §„Die kanonischen Namen der Agenten-Typen" (*„sie steht hier, damit sie nicht im Code lebt"*) ·
  `internal/span/emit.go:157-170` (`roleFromAgentType` — die zweite Kopie, in Go) ·
  `test/mutations/43-guard-blocked-union.sh` und `test/mutations/42-guard-baked-floor.sh` (die
  Bauform, mit der dieses Repo genau diese Drift bereits einmal bewacht hat) ·
  [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:73-76` · `:134-140`
- `befund`: Der Guard soll *„einen **Rollen**-Typ ablehnen, dessen `run_in_background` nicht
  `false` ist"* — ein Hintergrund-Aufruf mit `subagent_type: "general-purpose"` bleibt also
  erlaubt. Die Unterscheidung setzt die Liste der sechs kanonischen Namen voraus. Sie lebt heute
  an zwei Orten (Prosa in
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung), Ableitung
  in `roleFromAgentType`); ein bash-Guard wäre die dritte, und weder DoD (1) noch die
  Datei-/Komponenten-Tabelle nennt eine Quelle oder eine Kopplung. Der Alternativentwurf — der
  Guard liest `.claude/agents/*.md` — steht ebenfalls nirgends. Das Repo hat für exakt diese
  Klasse eine erprobte Antwort (`43-guard-blocked-union.sh` koppelt die BLOCKED-Menge des Guards
  an ihre zweite Fassung); der Plan ruft sie nicht auf.
- `failure-szenario`: slice-062 oder ein späterer Slice ergänzt eine siebte Rolle in
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) und in
  `roleFromAgentType`. Die bash-Liste im Guard bleibt bei sechs. Die neue Rolle darf im
  Hintergrund starten, ihre Zähler fehlen, und die Abdeckungszahl aus slice-066 fällt — der
  Befund liest sich wie ein Nutzungsproblem und ist eine Listen-Drift, die kein Sensor sieht.
- `verifizierbar`: ja, ohne Gate — `sed -n '73,76p;134,140p' docs/plan/planning/open/slice-060-rollen-achse.md`
  gegen `sed -n '157,170p' internal/span/emit.go` und
  `grep -n "planner\|validator" harness/conventions.md`.

### F-6 — Die Datei-/Komponenten-Tabelle hat in dieser Runde ihre `test/`-Zeile **verloren**, während der Slice ein Artefakt bekam, dessen Sensor genau dort liegt

- `kategorie`: **MEDIUM**
- `quelle`: Modul 5 §Ziel-Form: Slice (die Tabelle sagt, was angefasst wird) ·
  `test/guard.bats` (der Ort, an dem Guard-Verhalten in diesem Repo geprüft wird) ·
  Runde-3-Befund F-12 (dieselbe Tabelle, dieselbe Klasse)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:134-140`, Zeile `test/mutations/`
- `befund`: Vor `b093502` führte die Tabelle *„`test/` + `test/mutations/` | neu | der Zahn aus
  DoD (2)"*. Danach führt sie *„`test/mutations/` | neu + update | **fünf** Zähne aus DoD (2)"* —
  die DoD-(2)-Seite ist korrekt nachgezogen, die Zeile `test/` ist **entfallen**. Im selben Commit
  kam mit dem `PreToolUse`-Guard ein Artefakt hinzu, dessen Verhaltens-Prüfung in diesem Repo
  ausschließlich in `test/guard.bats` liegt. Die Tabelle budgetiert damit fünf Zähne für DoD (2)
  und **null** für DoD (1) — weder bats-Test noch Mutations-Fall. Das ist die Korrektur eines
  Runde-3-Befunds, die an derselben Tabelle einen neuen aufmacht.
- `failure-szenario`: Der Implementer arbeitet die Tabelle ab (sie ist die kürzere Liste), baut
  den Guard, schreibt fünf Mutations-Fälle für die Positiv-Liste und keinen Test für den Guard.
  `make gates` ist grün (der Guard ist verdrahtet und tut etwas), `make mutate` ist grün (der
  Guard ist nicht gelistet). DoD (1) ist abgehakt, die Vordergrund-Bedingung ist unbewacht — und
  das war der Gegenstand des Runde-3-HIGH.
- `verifizierbar`: ja, ohne Gate — `git show b093502 -- docs/plan/planning/open/slice-060-rollen-achse.md | grep -n "^[-+].*test/"`.

### F-7 — slice-066 DoD (2) beantwortet zwei der vier Modul-15-Fragen nicht, sondern wiederholt sie; und die festgelegte Aggregation `hits / (hits + misses)` hat im Plan keine Zuordnung, welcher Payload-Zähler `hits` ist

- `kategorie`: **MEDIUM**
- `quelle`: `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` §Cache-Counter-Regeln
  (Tabelle: Name · Unit/Cardinality · Labels · Aggregation) ·
  `docs/plan/planning/welle-09-modul-15-konformitaet.md:17-18` (*„entweder einen laufenden Sensor
  oder eine deklarierte Entscheidung … und nichts dazwischen"*) · `:147-154` (die höherrangige
  Quelle nennt die Zuordnung: *„getrennten Hit-/Miss-Zählern (`cache_read_input_tokens` vs.
  `cache_creation_input_tokens`)"*)
- `pfad`: `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:59-69`
- `befund`: Der Runde-3-Befund F-5 verlangte, dass **alle vier** Fragen je Counter beantwortet
  sind. Aufgenommen sind jetzt alle vier — beantwortet sind zwei. Punkt 1 lautet *„**Name** — je
  Counter ausgeschrieben, nicht umschrieben"* und Punkt 2 *„**Unit/Cardinality** — Counter, Gauge
  oder Histogram"*: das sind die Fragen des Moduls in Imperativ-Form, keine Entscheidungen. Punkt 3
  (Labels) und Punkt 4 (Division im Auswerter) sind echte Antworten. Konkrete Folge: Punkt 4 legt
  `hits / (hits + misses)` fest, ohne dass irgendwo im Slice steht, welcher der zwei
  Payload-Zähler `hits` ist — die Zuordnung steht **nur** in der höherrangigen welle-09 §4, und
  beide Größen sind **Token**-Zahlen, keine Ereignis-Zähler. Ob die Rate über Token oder über
  Aufrufe gebildet wird, ist genau die Frage, die Punkt 2 (Unit/Cardinality) klären soll und
  offen lässt; die Formel steht trotzdem fest.
- `failure-szenario`: Der Implementer bildet `cache_read / (cache_read + cache_creation)` über
  Token-Summen und weist es als *Cache-Hit-Rate* aus. Ein einziger großer Kalt-Aufruf verschiebt
  die Zahl um Dutzende Prozentpunkte, weil ein Miss viele Token wiegt und ein Hit wenige. Die
  Bilanz meldet einen Cache-Einbruch, wo eine Sitzungsstruktur wechselte — und Modul 15 führt den
  Miss-Spike ausdrücklich als **Sicherheits**-Indikator, an dem eine falsche Basis nicht folgenlos
  ist.
- `verifizierbar`: ja, ohne Gate —
  `sed -n '/### Cache-Counter-Regeln/,/### Doku-Konsistenz/p' .harness/baseline/v3.5.2/regelwerk/modul-15-observability.md`
  gegen `sed -n '59,77p' docs/plan/planning/open/slice-066-telemetrie-auswertung.md` und
  `sed -n '147,154p' docs/plan/planning/welle-09-modul-15-konformitaet.md`.

### F-8 — Die zwei deklarierten Entscheidungen in DoD (2) tragen keinen Auflösungs-Trigger, den die Welle für jede Deklaration verlangt; und der dritte Counter ist ein zweiter Liefergegenstand im selben Punkt

- `kategorie`: **MEDIUM**
- `quelle`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:16-18` und `:91`/`:93` (*„**deklariert**
  … Geltungsbereich, Begründung, **Auflösungs-Trigger**"*; *„eine Entscheidung ohne Trigger ist
  nach Modul 7 die permanente Ausnahme, die lügt"*) ·
  `.harness/baseline/v3.5.2/regelwerk/modul-05-planning-harness.md:71`/`:79-81` (≤ 3 DoD-Punkte,
  einzeln lieferbar)
- `pfad`: `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:66-77`
- `befund`: Zwei Deklarationen sind neu: *„Hier: im Auswerter, weil dieses Repo weder Metrik-DB
  noch Dashboard hat"* und *„**Deklarierte Entscheidung:** alle drei werden geführt"*. Beide sind
  begründet und im Geltungsbereich klar; **keine** nennt den Auflösungs-Trigger, den §3 der Welle
  für den Wert „deklariert" ausdrücklich fordert (etwa: *sobald ein Metrik-Ziel existiert, wandert
  die Division dorthin*). Zweitens verschiebt die dritte-Counter-Entscheidung den Zuschnitt: die
  Token-Eingabe-Metrik (`input_tokens`) ist **kein Cache-Zähler**, sie wird von DoD (1) bereits je
  Rolle summiert, und die in Punkt 4 festgelegte Aggregation `hits / (hits + misses)` ist für sie
  sinnlos — die Zusage *„mit allen vier Angaben, die die Regel je Counter verlangt"* ist für den
  dritten Counter als geschrieben nicht erfüllbar. Formal hält Modul 5 (3 slice-eigene DoD-Punkte
  je Slice, gemessen: je 6 Kästchen, davon 3 aus der Vorlage); der Punkt trägt aber vier
  nummerierte Unterbedingungen plus zwei Deklarationen plus eine Metrik aus einem anderen Block.
- `failure-szenario`: welle-09 wird geschlossen. Die 4×2-Matrix trägt für Block 3 den Wert
  „deklariert" — die Zelle verlangt einen Auflösungs-Trigger, es gibt keinen, und niemand merkt
  es, weil die Deklaration im Slice-DoD steht und nicht als `MR-<NNN>`. Die Entscheidung
  *„Division im Auswerter"* wird damit zur permanenten Ausnahme, die §3 der Welle beim Namen
  nennt.
- `verifizierbar`: ja, ohne Gate — `sed -n '16,18p;88,95p' docs/plan/planning/welle-09-modul-15-konformitaet.md`
  gegen `sed -n '59,77p' docs/plan/planning/open/slice-066-telemetrie-auswertung.md`.

### F-9 — Nach dem Entfernen von [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) ruht die `requirement`-Achse beider Slices allein auf [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) — und zwar in einer Ebenen-Lesart, die der Vorgänger-Slice für dieselbe Kennung anders trifft

- `kategorie`: **MEDIUM**
- `quelle`: [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
  (*„**Das Tool** ist ein natives Go-Binary … Der **Tool-Build** läuft … kein Host-`go` …
  **Emittierte Ziel-Repos** bleiben make/docker-getrieben"*) ·
  `docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md:16-17` (dieselbe Kennung, gelesen
  als *„die Zusage für die **emittierte** Seite"*) · Memory-Regel *„Dogfood vs. emittiert"* ·
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) §Geschichte Runde 2 (*„[`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
  war falsch zitiert und auf das Ziel verengt"*) · `internal/span/emit.go:409-429`
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:17-19` ·
  `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:22-23`
- `befund`: Die Entfernung von
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) ist
  richtig und mechanisch korrekt ausgeführt (`c0243e4`). Sie lässt slice-060 mit **genau einer**
  `LH-*`-Kennung zurück, und deren Ebenen-Zuweisung ist neu und ungeprüft: beide Slices lesen
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) jetzt als
  *„**Dogfood-Ebene**: das Werkzeug **dieses** Repos, nicht das emittierte Zielprojekt"*, während
  der geschlossene Vorgänger slice-059 dieselbe Kennung als *„die Zusage für die **emittierte**
  Seite"* führt. Der Anforderungstext trägt beide Hälften, aber sein Subjekt ist *„Das Tool"* —
  das Produkt-Binary; slice-066 §3 schließt ausdrücklich aus, eines zu bauen (*„**kein**
  Subkommando des Produkt-Binaries"*). Damit ist die Frage, die für
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) gestellt
  und beantwortet wurde, für die verbliebene Kennung nicht gestellt — und dieselbe Kennung ist in
  diesem Umfeld schon einmal falsch zitiert worden (ADR-Runde 2, welle-09 §6).
- `failure-szenario`: Der Emitter schreibt für die gesamte Laufzeit von slice-060
  `requirement: ["LH-QA-03"]`. Wer später fragt *„was hat die Zusage minimaler Abhängigkeiten
  gekostet"*, bekommt die Kosten einer Telemetrie-Arbeit; wer dieselbe Achse für slice-059 liest,
  bekommt sie unter der gegenteiligen Ebenen-Lesart. Zwei Slices derselben Welle buchen auf eine
  ID mit zwei Bedeutungen — gefüllt und mehrdeutig, was die Korrektur gerade vermeiden wollte.
- `verifizierbar`: ja, ohne Gate — `sed -n '268,278p' spec/lastenheft.md` gegen
  `sed -n '16,19p' docs/plan/planning/open/slice-060-rollen-achse.md` und
  `sed -n '16,17p' docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md`.

### F-10 — Der Umdeutungs-Absatz in [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) steht mitten in der nummerierten Liste „Vier erklärte Abweichungen" und behauptet „hier und nur hier"

- `kategorie`: **LOW**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.4 (die Umdeutung gehört nicht in die ADR — geprüft
  und eingehalten) · [`AGENTS.md`](../../AGENTS.md) §3.6 (Vollständigkeitsaussage) ·
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:78`, `:361`, `:375` (die drei Fundstellen,
  auf die sich die Umdeutung bezieht)
- `pfad`: `harness/conventions.md:924-930` · `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:16-19`
- `befund`: Die Verankerung schließt den Runde-3-Befund F-8 — sie steht auffindbar und begründet
  ausdrücklich, warum die ADR nicht angefasst wird. Zwei Nebenpunkte: **(a)** Der Absatz ist
  zwischen Punkt 1 und Punkt 2 der Liste *„Vier erklärte Abweichungen vom Modul-15-Pflicht-Minimum"*
  eingesetzt, auf einer flacheren Einrückung als die Punkte selbst — er zerlegt die Vierer-Liste
  in „1 · Absatz · 2–4" und liest sich wie ein Teil der Cache-Status-Abweichung, mit der er nichts
  zu tun hat. **(b)** Der Satz *„Diese Umdeutung steht hier und nur hier"* ist eine
  Vollständigkeitsaussage; slice-066 führt denselben Sachverhalt inhaltlich in seinem Bezug-Block
  (*„die ADR nennt den Auswerter dreimal ‚slice-060', gemeint ist seit dem Schnitt **dieser**
  Slice"*), zeigt also nicht bloß hierher, sondern wiederholt die Aussage.
- `failure-szenario`: Jemand pflegt die Abweichungs-Liste (etwa wenn der Cache-Status wirklich
  erfasst wird), fasst Punkt 1 an und nimmt den anliegenden Absatz als dessen Fortsetzung mit —
  die Umdeutung verschwindet mit einer Änderung, die sie nicht meinte, und die
  ADR-Re-Evaluierungs-Trigger zeigen wieder ins Leere.
- `verifizierbar`: ja, ohne Gate — `sed -n '915,932p' harness/conventions.md` (Einrückung der
  Marken `1.`/`2.` gegen den Absatz) und `grep -rn "slice-066" harness/conventions.md docs/plan/planning/open/`.

### F-11 — [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) Abweichung 1 ersetzt das gerügte Präsens durch eine Lifecycle-Position, die schneller altert als der Satz davor

- `kategorie`: **LOW**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.1 · Memory-Regel *„Zusage vs. Abdeckung"*
  (Prozess-Zustand gehört nicht in ein bindendes Dokument) ·
  `docs/plan/planning/README.md` (der Zustand **ist** das Verzeichnis)
- `pfad`: `harness/conventions.md:920-923`
- `befund`: Der Runde-3-Befund F-13 ist sachlich geschlossen — die Adaption sagt jetzt sauber,
  dass die *Messung* belegt und die *Erfassung* nicht erreicht ist. Der gewählte Beleg dafür ist
  aber eine Momentaufnahme des Lifecycles: *„slice-060 ist geplant, **liegt in `open/`**"*. Diese
  Aussage wird beim ersten `git mv` falsch, und sie steht in einer **bindenden** Adaption, die
  kein Gate gegen die Verzeichnis-Position hält.
- `failure-szenario`: slice-060 wandert nach `in-progress/`. Ein Leser der Adaption schließt aus
  *„liegt in `open/`"*, die Arbeit habe noch nicht begonnen, und plant den Cache-Status erneut ein
  — oder er hält die Adaption für gepflegt, weil sie so konkret klingt.
- `verifizierbar`: ja, ohne Gate — `sed -n '917,925p' harness/conventions.md` gegen
  `ls docs/plan/planning/open/`.

### F-12 — [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) verankert zwei von vier `scan.ignore`-Einträgen; für die anderen zwei gilt das Failure-Szenario des Befunds unverändert weiter

- `kategorie`: **LOW**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.5 (geprüft und **nicht** verletzt — Scoping, wie die
  Adaption selbst richtig sagt) ·
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) ·
  `.d-check.yml:17`
- `pfad`: `harness/conventions.md:56-63` gegen `.d-check.yml:17`
- `befund`: Die Verankerung schließt den Runde-3-Befund F-10 für
  `docs/user/claude-hooks-referenz.md` und ordnet ihn korrekt neben
  [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  ein. Die reale Liste hat **vier** Einträge:
  `**/*.template.md`, `.tmp/**`, `.harness/baseline/**`, `docs/user/claude-hooks-referenz.md`.
  Die Adaption nennt die letzten zwei und begründet sie als *„vendored Fremd-Dokumente"* — für die
  ersten zwei bleibt es beim YAML-Kommentar bzw. bei gar keiner Begründung. Das Failure-Szenario,
  mit dem der Runde-3-Befund begründet war (jemand räumt die Ignore-Liste auf und entfernt einen
  Eintrag ohne Adaptions-Rückhalt), trifft nach der Korrektur genau die zwei übrigen.
- `failure-szenario`: `**/*.template.md` wird beim Aufräumen entfernt, weil kein `MR` ihn trägt;
  `make docs-check` fällt über die Ziel-Form-Templates der vendored Baseline, deren Platzhalter nie
  für dieses Repo gedacht waren.
- `verifizierbar`: ja, ohne Gate — `sed -n '17p' .d-check.yml` gegen `sed -n '50,64p' harness/conventions.md`.

### F-13 — Der als Vorbild benannte Entscheidungs-Kanal des bestehenden Guards ist für `PreToolUse` laut der vendored Referenz **veraltet**

- `kategorie`: **LOW**
- `quelle`: `docs/user/claude-hooks-referenz.md:1645` (*„PreToolUse verwendete zuvor Top-Level-Felder
  `decision` und `reason`, diese sind jedoch für dieses Ereignis **veraltet** … Die veralteten Werte
  `"approve"` und `"block"` werden auf `"allow"` und `"deny"` abgebildet"*) ·
  `.claude/hooks/pretooluse-command-guard.sh:34-42` (`emit_block` schreibt exakt
  `{"decision": "block", "reason": …}`)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:70-72`
- `befund`: DoD (1) verweist auf den bestehenden Guard als Bauvorbild und hebt seinen
  Entscheidungs-Weg ausdrücklich hervor (*„er verweigert über den Entscheidungs-Kanal, nicht über
  den Exit-Code"*). Der bestehende Guard benutzt für `PreToolUse` den **abgekündigten** Top-Level-
  Kanal; die aktuelle Form ist `hookSpecificOutput.permissionDecision: "deny"`. Der Hinweis fehlt
  im Plan, obwohl er in derselben vendored Datei steht, aus der der Plan seine übrigen Hook-Fakten
  zieht.
- `failure-szenario`: Der neue Guard wird nach dem alten Muster gebaut. Fällt die
  Abwärtskompatibilität in einer künftigen Werkzeug-Version, verweigert er nicht mehr — der Aufruf
  läuft durch, der Hintergrund-Start passiert, und die Zähler fehlen **lautlos**: genau der
  Fehlerpfad, den DoD (1) schließen soll, an der Stelle, an der der Plan den alten Guard als
  Beleg für Machbarkeit anführt.
- `verifizierbar`: ja, ohne Gate — `sed -n '1645p' docs/user/claude-hooks-referenz.md` gegen
  `sed -n '34,42p' .claude/hooks/pretooluse-command-guard.sh`.

### F-14 — „Der Mechanismus … blockt Tool-Calls anhand ihrer `tool_input`" überzeichnet, was wiederverwendbar ist: der vorhandene Extraktor liest genau ein Feld und fällt sonst fail-closed

- `kategorie`: **LOW**
- `quelle`: `.claude/hooks/pretooluse-command-guard.sh:7-11` (*„der awk-Extraktor … zieht **nur das
  eine Feld** `tool_input.command` … bei Parse-Zweifel → fail-closed (block)"*) · `:106-115` (ohne
  `awk` bzw. bei `rc != 0` → `emit_block`)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:68-72`
- `befund`: Der Satz stimmt für die **Verdrahtung** und für die Blockier-Ausgabe; für das Lesen
  der Eingabe nicht. Der vorhandene Guard kennt genau ein `tool_input`-Feld (`command`) und
  behandelt jede Payload, aus der der Extraktor es nicht zieht, als Parse-Zweifel → `block`. Auf
  `Agent` unverändert angewandt hätte er die Wahl zwischen „blockt jeden Agenten-Aufruf" und „liest
  nichts". Der neue Guard braucht folglich eine **eigene** Feld-Extraktion für zwei Felder
  (`subagent_type`, `run_in_background`) und eine eigene fail-closed-Politik — die Tabelle sagt
  das mit *„update + neu"* implizit, der DoD-Text stellt es als vorhandene Fähigkeit dar.
- `failure-szenario`: Der Aufwand wird beim Schneiden zu klein veranschlagt („der Guard existiert
  ja"), der Slice läuft über, und die fail-closed-Politik für den neuen Fall wird beim Bauen ad hoc
  entschieden statt im Plan — bei einem Bauteil, das jeden Agenten-Aufruf des Repos passiert.
- `verifizierbar`: ja, ohne Gate — `sed -n '1,30p;106,116p' .claude/hooks/pretooluse-command-guard.sh`
  gegen `sed -n '68,72p' docs/plan/planning/open/slice-060-rollen-achse.md`.

### F-15 — welle-09 §1/§4 beschreiben in derselben Passage, die zweimal angefasst wurde, weiter den Zustand **vor** slice-059

- `kategorie`: **LOW**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §2 (die Welle steht über dem Slice) ·
  `docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md` (**done**) ·
  `.claude/settings.json:14-33` (`PostToolUse`/`PostToolUseFailure` → `span-emit`)
- `pfad`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:49-52` · `:143-145`
- `befund`: Der Absatz *„Zu slice-066"* ist korrekt nachgezogen (Runde-3-F-7 geschlossen). Direkt
  darüber und in §1 steht unverändert: *„Diese Spans entstehen bei uns **heute nirgends**"* und
  *„der Erfassungsort existiert bereits: der `PreToolUse`-Guard sieht jeden Bash-Aufruf … und
  behält **nichts** davon"*. Seit slice-059 (**done**) entstehen die Spans, und zwar an
  `PostToolUse`/`PostToolUseFailure`, nicht am `PreToolUse`-Guard. Die höherrangige Quelle
  beschreibt an zwei Stellen einen überholten Ist-Zustand — in derselben Datei, deren §4 in dieser
  Runde zweimal korrigiert wurde.
- `failure-szenario`: Der Planner von slice-061/062 oder der Closure-Autor liest die Welle als
  Ist-Beschreibung, hält die Erfassung für offen und schneidet sie erneut — oder sucht den
  Erfassungsort am `PreToolUse`-Guard, wo er nicht ist.
- `verifizierbar`: ja, ohne Gate — `sed -n '49,52p;140,146p' docs/plan/planning/welle-09-modul-15-konformitaet.md`
  gegen `ls docs/plan/planning/done/slice-059-*` und `sed -n '14,33p' .claude/settings.json`.

### F-16 — Die Mutation des Grenz-Zahns setzt eine Implementierungs-Form voraus, die der Plan nicht festlegt; ist sie eine andere, ist der Fall nicht anwendbar

- `kategorie`: **INFO**
- `quelle`: [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) §Geschichte 2026-07-28
  (**R5-2**: *„der dafür eingesetzte Mutations-Fall wäre gar nicht ausführbar … die Mutation
  maskierte sich selbst"*) · `test/mutations/108-span-schema-offen.sh` und
  `test/mutations/115-span-ergebnis-inhalt.sh` (beide sind **einzeilige** `sed`-Eingriffe)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:101-104`
- `befund`: Der Grenz-Zahn ist inhaltlich richtig konstruiert (er trennt die Positiv-Liste von
  einer Vier-Namen-Filterung — siehe Negativbefunde). Seine Mutation ist als *„die Erfassung auf
  ‚alles außer den vier' umstellen"* beschrieben. Wird `tool_response` — wie `Payload` heute — in
  ein **geschlossenes Struct** dekodiert, ist das kein einzeiliger Eingriff, sondern ein Wechsel
  der Datenstruktur auf eine offene Map; alle bestehenden Span-Mutationen sind einzeilig. Der Plan
  legt die Form nicht fest, und dieses Repo hat für genau diese Klasse einen dokumentierten
  Präzedenzfall.
- `failure-szenario`: Der Fall wird beim Umsetzen als „nicht sinnvoll anwendbar" verworfen oder auf
  eine Variante zurechtgebogen, die die alte Implementierung misst statt der Eigenschaft. Der
  Grenz-Zahn — der einzige Zahn, der die Positiv-Liste **als Positiv-Liste** belegt — fällt weg,
  und die vier Namens-Zähne bleiben zurück: der Zustand, den Runde 3 F-2 beanstandet hat.
- `verifizierbar`: ja, ohne Gate — `sed -n '101,104p' docs/plan/planning/open/slice-060-rollen-achse.md`
  gegen `cat test/mutations/108-span-schema-offen.sh test/mutations/115-span-ergebnis-inhalt.sh`.

## Bilanz der Runde-3-Befunde

| # | Titel (Kurzform) | Kat. | Status | Beleg |
|---|---|---|---|---|
| F-1 | „Und sie hat keinen Sensor" + falsche Durchsetzungsorte | HIGH | **halb** | slice-060 `:65-76` ersetzt die Verneinung durch den Guard-Entwurf und benennt den Fehler in §6 selbst; slice-066 `:56` trägt den Satz unverändert weiter (F-1 dieses Reports) |
| F-2 | Positiv-Liste ohne Zahn auf der Grenze | MEDIUM | **geschlossen** | fünfter Zahn `:99-104`, mit benannter Mutation (*„alles außer den vier"*) — er trennt Positiv-Liste von Vier-Namen-Filterung; Restrisiko nur in der Ausführbarkeit (F-16, INFO) |
| F-3 | slice-066 liest `agentType`, slice-060 schreibt `spawned_role` | MEDIUM | **geschlossen** | vier Stellen nachgezogen: DoD (1) `:41`, Sammelposten-Key `:51`, §3-Voraussetzung `:90`, Frage A `:107` |
| F-4 | Frage C: Restliste unvollständig | MEDIUM | **geschlossen** | (a) Mehrfach-Treffer und (b) Zustands-Brücke stehen jetzt in `:149`; die ADR-Fundstelle wurde dabei falsch zurückgewiesen (F-2 dieses Reports) |
| F-5 | Cache-Counter-Regeln: zwei von vier Fragen | MEDIUM | **halb** | alle vier Fragen aufgenommen `:59-69`; Punkt 1 und 2 wiederholen die Frage, statt sie zu beantworten, und die Aggregation hat keine Zuordnung (F-7, F-8) |
| F-6 | slice-066 ohne ADR im Bezug | MEDIUM | **geschlossen** | `:16-21` führt [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) und [`ADR-0003`](../plan/adr/0003-go-native-binaries.md); Nachbildung von `references()` über den Block trägt beide |
| F-7 | welle-09 §4 begründet mit Transkripten, beschreibt 066 | MEDIUM | **geschlossen** | `:147-154` umbenannt und auf die gemessene Payload umgestellt; Restdrift in §1/§4 ist älter (F-15) |
| F-8 | ADR-Umdeutung nirgends verankert | MEDIUM | **geschlossen** | `harness/conventions.md:924-930` mit ausdrücklichem §3.4-Bezug; Platzierung ist der Restpunkt (F-10) |
| F-9 | `test/mutations/115` + §Bewacht + `span.go` werden falsch | MEDIUM | **geschlossen** | Datei-Tabelle `:137`/`:140` führt alle drei als `update`, samt der Feststellung, dass `make comment-claims` es nicht fängt |
| F-10 | `.d-check.yml`-Ausnahme ohne Verankerung | MEDIUM | **geschlossen** | [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) `:56-63`, korrekt als Scoping statt §3.5 eingeordnet; zwei weitere Einträge bleiben unverankert (F-12) |
| F-11 | Tabellenkopf „zwei Aufrufe" gegen vier Zeilen | LOW | **geschlossen** | `:115` und `:184` sagen beide **vier** |
| F-12 | Datei-Tabelle folgt der DoD nicht | LOW | **verschlimmert** | DoD-(2)-Seite korrekt nachgezogen (fünf Zähne, `spawned_role`, Positiv-Liste, neue `.claude/`-Zeile) — dabei ist die Zeile `test/` **entfallen**, während der Slice ein Artefakt bekam, dessen Sensor genau dort liegt (F-6) |
| F-13 | [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) Abweichung 1 im Präsens | LOW | **geschlossen** | `:920-923` trennt Messung und Erfassung sauber; die Lifecycle-Position ist der neue Restpunkt (F-11) |
| F-14 | „Offen, vor dem Code zu entscheiden" ohne blockierende Frage | LOW | **geschlossen** | Kopf `:142-144` sagt jetzt, was die Tabelle ist, und dass keine der Fragen Vorbedingung ist; B steht vor C |
| F-15 | „wörtlich" gegen fünf/sechs Rollen | LOW | **geschlossen** | `:46-50` nennt fünf und sechs ausdrücklich und sagt dem Verifier, wo die Differenz herkommt |
| F-16 | „Zwei namenlose Eimer" dreimal | LOW | **geschlossen** | gemessen: `grep -rn "namenlose" docs/plan/` → **ein** Treffer (welle-09 `:116`) |
| F-17 | `LH-*`-Kennungen der emittierten Ebene entnommen | LOW | **halb** | [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) entfernt und die Notiz nach `c0243e4` mechanisch korrekt platziert; die verbleibende Kennung trägt eine Ebenen-Lesart, die dem Vorgänger widerspricht (F-9) |

**Summe:** geschlossen **13** · halb **3** · verschlimmert **1** · offen **0**.
Nach Kategorie: der **1 HIGH halb** (in slice-060 geschlossen, in slice-066 offen); von 9 MEDIUM
sieben geschlossen, zwei halb; von 7 LOW fünf geschlossen, einer halb, einer verschlimmert.

## Negativbefunde

- geprüft, ohne Befund: **der Grenz-Zahn trifft die Eigenschaft, nicht nur einen fünften Namen.**
  Er füttert ein **ungelistetes, erfundenes** Feld und benennt die Mutation, unter der er rot wird
  (*„alles außer den vier"*). Unter dieser Mutation erreicht das erfundene Feld den Span → rot;
  eine Vier-Namen-Filterung ließe genau das durch. Damit unterscheidet er eine Positiv-Liste real
  von einer Negativ-Liste in Positiv-Kleidung — das war die Frage aus Runde 3 F-2, und sie ist
  beantwortet. Offen ist nur die Ausführbarkeit der Mutation (F-16, INFO).
- geprüft, ohne Befund: **die `run_in_background`-Polarität des Guards.** *„dessen
  `run_in_background` nicht `false` ist"* deckt den fehlenden Schalter **mit** ab — und genau der
  ist der Normalfall: `docs/user/claude-hooks-referenz.md:1567` sagt, dass ab v2.1.198 Subagenten
  **standardmäßig im Hintergrund** laufen und *„ein weggelassenes `run_in_background` auch
  `async_launched` erzeugt"*. Die Formulierung ist die richtige; eine Prüfung auf `== true` wäre
  am Standardfall vorbeigegangen.
- geprüft, ohne Befund: **`c0243e4` ist mechanisch korrekt.** `references()`
  (`internal/span/emit.go:409-429`) startet an `**Bezug:**` und bricht bei der ersten Zeile ab,
  deren `TrimSpace` leer ist; der Ausschluss-Absatz steht jetzt unterhalb dieser Leerzeile
  (slice-060 `:22` leer, `:23` Absatzbeginn). Der Bezug-Block trägt damit `ADR-0011` und
  `LH-QA-03` — die Nachbildung des Planers stimmt, an beiden Slices nachgerechnet.
- geprüft, ohne Befund: **Modul 5 §Größen-/Schnitt-Regeln, formal.** Gemessen
  `grep -c '^- \[ \]'` → je **6**, davon 3 aus der Vorlage; beide Slices halten also die Grenze von
  ≤ 3 slice-eigenen DoD-Punkten. Beanstandet ist die **Dichte** eines Punktes (F-8), nicht die
  Zahl — und die Beanstandung ist inhaltlich (der dritte Counter gehört sachlich nicht in einen
  Cache-Zähler-Punkt), nicht formal.
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.4.** Weder die ADR-Umdeutung noch die
  Aufnahme von `Agent` in die Werkzeug-Liste fasst
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) an; die Umdeutung sagt das
  ausdrücklich. Eine Supersedes-ADR ist weiterhin **nicht** nötig. (Die falsche Aussage **über**
  die ADR in F-2 ist ein §3.6-Befund, kein §3.4-Befund — die Datei selbst ist unberührt.)
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.5.** Die
  `.d-check.yml`-`scan.ignore`-Ausnahme ist **Scoping**, keine Gate-Lockerung: der Prüfumfang
  schrumpft nicht um eigenen Bestand, sondern um zwei Dateien, die dieses Repo spiegelt statt
  schreibt. [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  ordnet das selbst korrekt ein. Kein ADR nötig; keine der Delta-Änderungen senkt eine Schwelle
  oder deaktiviert ein Modul.
- geprüft, ohne Befund: **`matcher: "Agent"` ist als Wert zulässig** — `docs/user/claude-hooks-referenz.md:214`
  (`PreToolUse` filtert auf **Tool-Name**), `:197` (reiner Buchstaben-Matcher = exakter
  String-Vergleich, kein Regex-Pfad, keine Anker nötig) und `:1438` (`Agent` ist namentlich in der
  `PreToolUse`-Tool-Liste). Der Entwurf ist also **nicht** von vornherein untauglich; beanstandet
  ist, dass der Plan diese Belege nicht führt und die Sache nicht gemessen hat (F-3).
- geprüft, ohne Befund: **die Zitate zu Modul 15 im Delta tragen.** §Cache-Counter-Regeln nennt
  wirklich *drei* Counter und stellt genau *vier* Fragen (Name · Unit/Cardinality · Labels ·
  Aggregation); die Labels sind *„mindestens `slice.id`, `agent.role`, `model.version`"*; die
  Aggregations-Frage lautet wörtlich *„wo wird die Division ausgeführt"*; das
  `cache.hit_ratio`-Argument (*Kosten- gegen Sicherheits-Indikator*) ist korrekt
  wiedergegeben; §Token-Attributions-Regeln zählt tatsächlich fünf Rollen. Auch der
  Miss-Spike-Satz, aus dem der dritte Counter abgeleitet wird, steht so im Modul. **Beanstandet
  ist die Folgerung, nicht das Zitat.**
- geprüft, ohne Befund: **die Bauform des Zahns wäre verfügbar.** `test/guard.bats` prüft
  Guard-Verhalten über stdin-Payloads und `assert_blocked`/`assert_passed`;
  `test/mutations/42`/`43` sind die zugehörigen Mutations-Fälle. Ein Zahn für den neuen Guard ist
  also mechanisch machbar — beanstandet ist, dass DoD (1) ihn nicht als Gegenbeispiel formuliert
  (F-4) und die Tabelle ihn nicht budgetiert (F-6).
- geprüft, ohne Befund: **Ziel-Form Slice** — Lifecycle-Block, Welle-Bezug, Bezug, Autor/Datum,
  §1–§8 in der Vorlagen-Reihenfolge; §8 Sub-Area-Modus-Begründung in beiden Slices vorhanden. Das
  Delta hat die Struktur nicht beschädigt.
- **Nicht geprüft** (Ressourcen-Schranke, ausdrücklich benannt statt verschwiegen): kein
  `make gates`, kein `make docs-check`, kein `make mutate`, keine eigene Payload-Messung — und
  damit insbesondere **nicht** die Behauptung aus beiden Commit-Messages, `make gates` sei mit
  Exit 0 (d-check 245/0 · comment-claims 36/0) gelaufen.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 2 |
| MEDIUM | 7 |
| LOW | 6 |
| INFO | 1 |

Zuordnung: **slice-060** trägt F-2, F-3, F-4, F-5, F-6, F-9 (mit), F-13, F-14, F-16;
**slice-066** trägt F-1, F-7, F-8, F-9 (mit); **welle-09/Adaptions-Umfeld** trägt F-10, F-11,
F-12, F-15.

## Verdikt

**Merge-blockierend:** **ja** — für beide Slices.

**slice-060 (Rollen-Achse): NICHT KONFORM.**

Blockierend ist **F-2**. Der Runde-3-Verweis auf
[`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 4 war **korrekt**;
zurückgewiesen wurde er mit *„die Festlegung hat drei Punkte"*. Sie hat fünf, Punkt 4 ist genau die
zitierte Regel (*„Die Ableitung muss ihre Randfälle mitentscheiden, sonst ist sie keine"*), und
derselbe Slice beruft sich elf Zeilen weiter auf **Punkt 5**. Das ist [`AGENTS.md`](../../AGENTS.md)
§3.6 in der Commit-Message-Variante und zugleich die **dritte** Wiederholung derselben Klasse in
dieser Slice-Familie (ADR-Runde-5-HIGH, Plan-Runde-3-HIGH, hier) — nach
`.harness/skills/reviewer.md` §Kontext-Eskalation ein Steering-Loop-Signal, keine Einzelbeobachtung.
Bemerkenswert ist die Richtung: die Fehl-Klasse ist inzwischen erkannt, benannt und in §6 des
Slice selbst dokumentiert — und tritt im selben Commit erneut auf, nur eine Ebene weiter (über die
**Struktur** einer Quelle statt über die **Existenz** eines Sensors).

Zum neuen Liefergegenstand, ausdrücklich beantwortet: **der Guard-Entwurf ist tragfähig, aber
unbelegt.** `matcher: "Agent"` ist ein zulässiger, dokumentierter Wert (`:214`, `:197`, `:1438`) —
die Richtung stimmt, und die Polarität *„nicht `false`"* trifft den Standardfall korrekt. Belegt
hat das der Plan **nicht**: er führt keine dieser Zeilen, misst nichts, und stützt sich auf
„der Mechanismus läuft hier bereits", was für `"matcher": "Bash"` gilt und über `Agent` nichts
aussagt (**F-3**). Das zweite tragende Feld, `run_in_background`, steht **nicht** im dokumentierten
`Agent`-Eingabeschema — es ist einmal gemessen worden, und das ist nach der eigenen Regel die
stärkere Quelle, gehört aber genau deshalb als Abhängigkeit von einer ungepinnten Oberfläche
benannt. Dazu: der Zahn ist als Testfall formuliert, nicht als Gegenbeispiel (**F-4**), die
Rollen-Liste, ohne die der Guard nicht unterscheiden kann, hat keine benannte Quelle und keine
Kopplung (**F-5**), und die Datei-Tabelle hat in derselben Korrektur ihre `test/`-Zeile verloren
(**F-6**). Der Entwurf ist damit die richtige Antwort auf den Runde-3-HIGH — mit derselben
Belegdichte, die den Runde-3-HIGH ausgelöst hat.

**slice-066 (Telemetrie-Auswertung): NICHT KONFORM.**

Blockierend ist **F-1**: die als falsch erkannte und in slice-060 zurückgezogene Aussage *„hat
keinen Sensor"* steht in slice-066 wörtlich weiter — und widerspricht damit dem Slice, auf dem er
aufsetzt. Vor der Korrektur trugen beide Slices dieselbe falsche Aussage; nach der Korrektur trägt
die Welle einen Widerspruch. Der bessere Grund, aus dem die Abdeckungszahl bleibt, steht in der
Commit-Message und in slice-060 §6 — nur nicht dort, wo die Abdeckungszahl verlangt wird.
Dazu **F-7** (von den vier Modul-15-Fragen sind zwei als Frage wiederholt statt beantwortet; die
festgelegte Aggregation hat keine Zuordnung, welcher Token-Zähler `hits` ist) und **F-8** (beide
neuen Deklarationen ohne den Auflösungs-Trigger, den die Welle für den Matrix-Wert „deklariert"
verlangt; der dritte Counter ist sachlich ein zweiter Liefergegenstand im selben DoD-Punkt).

**Zu den Auftragsfragen, ausdrücklich beantwortet.**
*Halten die Korrekturen?* **13 von 17 geschlossen, 3 halb, 1 verschlimmert, 0 offen.** Die eine
Verschlimmerung ist F-12: die Datei-Tabelle wurde der DoD nachgezogen und verlor dabei die Zeile,
die den Sensor des neuen Guards getragen hätte.
*Feuert `PreToolUse` bei `Agent`?* **Laut der vendored Referenz ja** (`:1438`, `:214`) — **im Plan
weder zitiert noch gemessen** (F-3).
*Deckt der Guard, was er verspricht?* **Die Polarität ja** (*„nicht `false`"* fängt den fehlenden
Schalter, und fehlend ist der Normalfall), **die Rollen-Unterscheidung nein** — woher die Liste
kommt, sagt kein Plan (F-5).
*Ist der Zahn ein Zahn?* **Als Bauform machbar, als Zusage nicht formuliert** — DoD (1) nennt den
Testfall, nicht das Gegenbeispiel, und kein Artefakt der Tabelle trägt ihn (F-4, F-6).
*Trifft der fünfte Zahn die Eigenschaft?* **Ja** — er ist der einzige der fünf, der eine
Positiv-Liste von einer Vier-Namen-Filterung trennt (Negativbefund). Restrisiko nur in der
Ausführbarkeit der Mutation (F-16).
*Trägt die Entscheidung zum dritten Counter?* **Die Zahl ja, die Einordnung nein** — das Modul
nennt drei Counter und die Payload zwei, und der Miss-Spike-Satz stützt `input_tokens`; aber die
Größe ist kein Cache-Zähler, wird von DoD (1) bereits summiert, und die für „je Counter"
festgelegte Aggregation ist für sie sinnlos (F-8).
*Ist die DoD noch **ein** Punkt?* **Formal ja** (3 und 3, gemessen), **sachlich trägt DoD (2) zwei
Gegenstände**.
*Ist die `requirement`-Achse nach dem [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)-Entfernen richtig gefüllt?* **Der Ort ja, die Kennung fraglich** —
`c0243e4` ist mechanisch korrekt nachgerechnet; die verbliebene Kennung
[`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) trägt eine Ebenen-Lesart,
die dem Vorgänger slice-059 für dieselbe ID widerspricht (F-9).
*Halten die zwei neuen Verankerungen gegen §3.4 und §3.5?* **Ja, beide** — die ADR bleibt
unangetastet, die `scan.ignore`-Ausnahme ist Scoping. Restpunkte sind Platzierung (F-10) und
Vollständigkeit der Aufzählung (F-12).
*Ist welle-09 §4 den Slices jetzt widerspruchsfrei?* **Der korrigierte Absatz ja** — die
Nachbarschaft beschreibt weiter den Zustand vor slice-059 (F-15).

**Übergabe:** Findings gehen an die Planung (Rückkante Review → Plan bei Plan-Defekt). Der Report
ersetzt keine Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11). **Vor der
Umsetzung zwingend zu klären ist eine Sache:** ob der `PreToolUse`-Guard auf `Agent` die
Vordergrund-Bedingung wirklich durchsetzen kann — **gemessen**, nicht aus der ungepinnten Referenz
geschlossen, und einschließlich der Frage, woher der Guard die Liste der Rollen-Typen nimmt. An
dieser einen Antwort hängen DoD (1) von slice-060 **und** die Begründung der Abdeckungszahl in
slice-066; der Plan hat für drei kleinere Fragen bereits gemessen, und jede dieser Messungen hat
eine Erwartung des Planers widerlegt.
