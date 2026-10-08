# Verifikation: slice-ausnahme-grund-nennt-seinen-ganzen-gegenstand — 2026-10-08

**Rolle:** Verifier (Modul 11) · **Gegenstand:** `748c0180..33ba1221` gegen den Slice-Plan
(`in-progress/`, Welle `welle-emittiertes-doc-gate`) und
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6); Review
`2026-10-08-ausnahme-grund-review.md` (F-1 HIGH, F-2/F-3 MEDIUM).

**Messweg:** Varianten als `git archive HEAD`-Kopie im Scratchpad (kein Worktree, Baum unberührt),
je `docker build --target test` und `go test` mit `--network none`, `--pids-limit 512`, `--memory 1024m`
(Parameter wie `make test-go`). Dazu `make mutate` über 579/580/581. `make gates` nicht gefahren: der
Gate-Stempel `.harness/state/gates-passed.head` = `33ba1221` = HEAD, und dieser Lauf ändert nur
den Bericht.

## Verdikte je DoD-Punkt

- **(1) Begründung nennt jeden Baum — bedingt.** Bestätigt für die erfassten Schlüssel
  (`scan.ignore`, `*.exempt-paths`, `codepaths.ignore-refs`, `ignore-refs.in`): `go test ./...` auf
  HEAD ohne `FAIL`. Grenzen: Die Schlüssel `exempt-targets`, `exclude-sections`, `exempt-pattern` und
  `refs` sind laut Paketkopf nicht erfasst und nennen ihren Gegenstand nach Argument selbst, nicht
  nach Sensor. Glob-Treffer unter `.harness/baseline/` misst der Repo-Fall nicht (Testkopf). Der
  emittierte Fall misst die Baseline-Fixture, nicht den realen Kurs-Satz (Testkopf). Alle Grenzen
  stehen am Sensor. Rot: `make mutate MUTATE_CASES="579-… 580-… 581-…"` → `3 ok, 0 Befund(e)`.
- **(2) Wächter und Grenze — bestätigt.** Die Grenze steht im Kopf von
  `internal/ausnahmegrund/ausnahmegrund.go` und wurde mit der Behebung nachgezogen (gelesene Formen,
  fail-closed für andere). Die Meldung nennt Eintrag und fehlenden Baum (siehe Rot-Belege unten).
- **(3) Ort der Regel — offen.** Das ist Architect-Arbeit (§1, §6 Risiko 2) und keine Verletzung.
  Den Register-Ausgang *verkörpert* trägt erst der Architect-Lauf.
- **`make gates` grün — bestätigt** über den Stempel auf HEAD (siehe oben).
- **Review — bestätigt:** Der Report liegt vor, Rollenwechsel per Commit `675bcd35`.
- **Doku-Update — bestätigt, entfällt:** Die emittierte Konfiguration ändert nur Kommentarzeilen, ihre
  Form bleibt (`git diff 748c0180 33ba1221 -- internal/emit/templates/d-check.yml`).
- **Closure-Punkte** (Notiz, Register, Risiko-Ausgänge, Paarungen) sind Sache des Planners und nicht
  geprüft.

## Behebung der Review-Findings (Rot-Belege)

Gefahren wurde eine Probe-Testdatei mit den Fällen des Reviews. Auf HEAD:

- `P3 Block single-quoted Zitat: err=<nil> eintraege=1 befunde=1 codepaths.ignore-refs tools/weg.sh (Zeile 4): die Begruendung nennt docs/ nicht`
  (im Review: `befunde=0`).
- `P1 scan.ignore Block-Liste: eintraege=1 befunde=1 scan.ignore .harness/** (Zeile 4): die Begruendung nennt .harness/skills/ nicht`
  (im Review: `eintraege=[]`).
- Unbekannte Formen (Skalar, Flow über zwei Zeilen) enden fail-closed:
  `err=scan.ignore (Zeile 2): Schreibform nicht gelesen: …`.

Bewusstes Brechen an der Ursache:

- **Quote-Behandlung auf den alten Stand zurück** (die Gruppe für einfache Anführungszeichen wird
  unerreichbar, der ungequotete Wert lässt `'` zu). Ergebnis: `TestEintraege_Schreibformen` rot mit
  `Block einfach gequotet (Zitat): erwartet [codepaths.ignore-refs="tools/weg.sh"], gelesen [… Wert:'tools/weg.sh' …]`,
  und die Probe P3 fällt auf `befunde=0` zurück. Die Ursache stimmt. Der Repo-Fall bleibt dabei grün,
  denn die reale `.d-check.yml` verwendet die Form nicht. Allein der Formen-Test hält diese Hälfte.
- **`scan.ignore` aus `erfasst` genommen** (`case false`). Rot werden
  `TestRepoKonfiguration_…` (`kein Eintrag unter scan.ignore gelesen … der Parser liest die Schreibform der Datei nicht mehr`),
  `TestEintraege_Schreibformen` (`scan.ignore Block-Liste: … gelesen []`) und
  `TestEintraege_UnbekannteFormFailClosed`. Damit ist auch F-2 auf der Repo-Seite belegt.
- **F-3:** Wird die alte `.dockerignore` (`.harness`) wiederhergestellt, wird
  `TestRepoKonfiguration_…` rot mit `.harness/skills/reviewer.md fehlt im Testbaum`. Kein anderer
  Test ändert sein Ergebnis.

## Gegenprobe Fall 581 (nachgetragen)

- Mutation 581 allein ergibt `--- FAIL: TestEintraege_UnbekannteFormFailClosed` mit
  `verschachteltes Item: erwartet Fehler mit "codepaths.ignore-refs (Zeile 4)", bekommen err=<nil>`.
  Das ist die Meldung aus dem Fallkopf.
- Mutation 581 zusammen mit `t.Skip` allein im benannten Test, dann `go test ./...`: keine
  `FAIL`-Zeile. Der benannte Test bindet also allein.

## `.dockerignore` (`.harness/*` + `!.harness/skills`)

- **Gate-Ergebnis:** Den Repo-Baum liest allein `internal/ausnahmegrund/ausnahmegrund_test.go`
  (`grep -rln 'filepath.Join("..", "..")' --include=*_test.go`). Mit der alten Datei wird nur dieser
  Fall rot, mit der neuen ist `go test ./...` grün. Die Änderung ist also Voraussetzung des eigenen
  Positiv-Belegs und färbt sonst nichts um.
- `compile`, `lint` und `build` kopieren `COPY . .`. Ihr Cache-Schlüssel wird damit um
  `.harness/skills/` breiter. Das ändert kein Urteil, kann aber zusätzliche Neubauten auslösen.
- **Offener Punkt (Zusage, Kommentar):** Drei Kommentare sagen weiter, dass `.harness/` ganz außerhalb
  des Kontexts liegt: `internal/emit/templates_test.go:231-232`, `internal/emit/templates.go:303-304`
  und `internal/archive/stub_test.go:59-60`. Der Commit `e7cebd16` hat die Bats- und Mutations-Köpfe
  nachgezogen, diese drei nicht. Ihre tragende Aussage (der vendored Kurs-Satz ist unsichtbar) bleibt
  wahr, der Wortlaut nicht.

## Plan-vs-Code

- Plan → Code: Alle fünf Zeilen aus §3 sind umgesetzt (zwei Konfigurationen, Paket, cmd-Fall,
  Mutations-Fälle 579/580).
- Code ohne Plan: die `.dockerignore`, Fall 581 und die Kommentarnachzüge in sechs
  Bats-/Mutations-Dateien. §3 („Fortgeschrieben im Implementierungs-Lauf“) nennt keinen dieser
  Posten. Sachlich folgen sie aus dem Review. Ob §3 nachgezogen wird, entscheidet der Planner.
- §5 Closure-Trigger 1 und 2: Die Liste der Einträge mit Gegenstand und Begründung sowie die
  gelesenen Rot-Ausgaben stehen in der Message von `f7d87bad`.

## Offen für Planner/Architect

- DoD 3 und §6 Risiko 2: Architect-Lauf für den Ort der Regel.
- Für die Quote- und `scan.ignore`-Hälfte von F-1 gibt es keinen Fall in `test/mutations/`. Ihre
  Haltbarkeit trägt allein `TestEintraege_Schreibformen` und der Repo-Fall, ohne Wächter in
  `make mutate`.
- Die drei veralteten `.dockerignore`-Kommentare (siehe oben).
- Der Plan §3 nennt `.dockerignore` und Fall 581 nicht.

**Negativbefunde:** Für die Behebung der drei Findings, die Gegenprobe 581 und die Wirkung der
`.dockerignore` auf die übrigen Tests liegt kein weiterer Befund vor.
