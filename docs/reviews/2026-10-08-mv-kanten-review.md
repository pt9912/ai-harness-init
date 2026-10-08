# Review — slice-mv-kanten-nach-done-sind-bewacht

**Rolle:** Reviewer (Skill `.harness/skills/reviewer.md`) · **Datum:** 2026-10-08 ·
**Gegenstand:** Commit `7720b489` (Claim `cec127bf`, `32ced978`, `e13b8086`) gegen den Slice-Plan
`slice-mv-kanten-nach-done-sind-bewacht` (Welle `welle-adopter-weg-im-ziel`) ·
**Bezug:** `LH-FA-01`, `LH-QA-01`, `AGENTS.md` §3.6/§3.7, `MR-071`.

## Summary

0 HIGH · 0 MEDIUM · 2 LOW · 2 INFO. Der Go-Wächter fährt den echten Aufrufer und misst die
Eigenschaften; die drei Mutations-Fälle binden; der `host-baum`-BEFUND tritt im sauberen
Nachlauf nicht auf.

## Findings

### F-1 — LOW

- `quelle`: `AGENTS.md` §3.6/§3.7
- `pfad`: `harness/tools/full-smoke.sh:3528`, `harness/tools/full-smoke.sh:3556`
- `befund`: Kommentar und Fehlermeldung geben für den docs-check vor dem ersten Wechsel einen
  Zweck an, den er nicht hat. Der Kommentar sagt *„damit das Gruen danach nicht schon vorher
  bestand"*, prüft aber gerade, dass das Grün vorher bestand. Die Meldung sagt *„das Gruen nach dem
  Wechsel saehe dann nichts"*, aber bei Befunden im Ausgangsstand wäre der Lauf danach rot und
  nicht blind. Was die Vorprüfung leistet: ein Befund danach lässt sich dem Wechsel zuordnen. Dass
  der docs-check die Planungsdateien überhaupt sieht, belegt allein Fall 591.
- `verifizierbar`: nein (Kommentar und Meldungstext; kein Gate liest sie)
- `klasse`: Begründung einer Vorprüfung nennt eine Wirkung, die sie nicht hat

### F-2 — LOW

- `quelle`: Maintainability (Doku-Drift)
- `pfad`: `harness/sensors/slice-mv.md:250`
- `befund`: §Im gebootstrappten Ziel — Grenze sagt noch, dass die Kette über der
  `--lang-go`-Variante gefahren wird und dass die sprachlose Lage allein `make test-go` hält
  (Pfade der Dateien). Die neue Stufe `slice_mv_kanten_nach_done_im_ziel` fährt die
  Zwei-Commit-Sequenz an einem sprachlosen Ziel (`ai-harness-init --name kd "$dir"` ohne
  `--lang`). Der Absatz unterschlägt damit eine Deckung, die jetzt besteht.
- `verifizierbar`: nein
- `klasse`: Grenz-Absatz nicht mitgezogen, als eine Stufe dazukam

### F-3 — INFO

- `quelle`: `AGENTS.md` §3.6 (Haltbarkeit über `make mutate`)
- `pfad`: `cmd/ai-harness-init/slice_mv_kanten_echt_test.go:144-171`
- `befund`: Die Zusage, dass eine Datei mit Präfix- und präfixloser Form in `eingehend:` einmal
  zählt, bindet der Test: Die Gegenprobe ersetzt im Zweig `*" $sf "*)` von `harness/tools/slice-mv.sh`
  das `;;` durch `in_count=$((in_count + 1)) ;;`, und beide Tests werden mit *„die Ausgabe nennt
  "eingehend: 3 …" nicht"* rot. Kein Fall unter `test/mutations/` hält diese Teil-Zusage dauerhaft,
  ebenso wenig den Ist-Bestand von Unterverzeichnis und ungetrackter Datei. Die DoD verlangt nur
  zwei Fälle, und `harness/sensors/slice-mv.md` schreibt nur 589/590 Rot zu. Beides stimmt.
- `verifizierbar`: ja (`make mutate`, sobald ein Fall existiert)
- `klasse`: Teil-Zusage durch Test gebunden, ohne Mutations-Fall

### F-4 — INFO (an den Planner, Risiko 1 aus §6)

- `quelle`: Slice-Plan §6 Risiko 1
- `pfad`: `cmd/ai-harness-init/slice_mv_kanten_echt_test.go:111`, `Makefile:518`
- `befund`: Der Test ruft `bash harness/tools/slice-mv.sh slice-kante done` mit Repo-Wurzel als
  Arbeitsverzeichnis. Das ist der Aufruf aus dem Rezept, und das Skript ist byte-gleich aus
  `sliceMvSkript` kopiert. Die Rezeptzeile `Makefile:518` selbst fährt der Test nicht. Die
  Entfallen-Bedingung aus Risiko 1 ist damit erfüllt, so wie sie formuliert ist. Über den Ausgang
  entscheidet der Planner.
- `verifizierbar`: nein
- `klasse`: —

## Gefahrene Proben

| Kommando | Ergebnis |
|---|---|
| `make mutate MUTATE_CASES=591-slice-mv-emittiert-ruft-die-praefixlose-ersetzung-nicht` (Host-Baum während des Laufs unberührt) | `ok 591-… -> ein Verweis auf die bewegte Datei loest nicht auf rot`, `1 ok, 0 Befund(e)`, kein `host-baum`, EXIT 0, 4m58s |
| Gegenprobe 590 in einer `git archive`-Kopie unter dem Scratchpad: Mutation angewandt, `t.Skip` **nur** in `TestSliceMvEchtKanteOpenNachDone`, `go test -run TestSliceMvEchtKante` im Image der `test`-Stage | Next bleibt rot (`3 von 4 Links loesen …`, `eingehend: … 0 praefixlose(r)`). Die Mutation hängt nicht an der Kante, daher färbt sie beide Tests: struktureller Nebeneffekt des gemeinsamen Helfers, kein Befund. Der Doc-Kommentar des Next-Tests sagt das zutreffend. |
| Dedup-Gegenprobe (F-3), gleiche Kopie | beide Tests rot an der Zeile `eingehend:` |

## Geprüft, ohne Befund

- **Go-Wächter (§3.6, `waechter-misst-die-fixture`):** Er fährt das reale Skript als Prozess, wie
  es das Rezept aufruft. Gehalten werden Exit, Commit-Zahl, Move-Betreff und `numstat` als reiner
  Rename, die Auflösung aller vier vorher gezählten Links (Positiv-Sonde `vorher != 4` vorhanden,
  keine leere Menge), die ausgehende Umschreibung, der vollständige Ist-Bestand von `<from>/` in
  beide Richtungen, `git status` und die Zählzeilen. In `make gates` läuft er über `test: test-bats test-go`.
- **full-smoke-Stufe und Deklaration:** Die Deklaration nennt, was gemessen wird (Exit, reiner
  Move, Auflösung über den docs-check des Ziels, auch vorher), und unter `NICHT gemessen` deckt sie
  sich mit der GRENZE im Kopfkommentar. Die emittierte `d-check.yml` schließt
  `docs/plan/planning/**` nicht aus (`scan.ignore` nur `**/*.template.md`, `.tmp/**`, `.harness/**`).
  `docs/user/e2e-abdeckung.md` ist erzeugt und nur neu nummeriert.
- **Mutations-Fälle 589–591 (MR-071):** Anker je Fall einmal im Quell-Bestand. Für 590 ist die
  Wirkung als Diff gesehen (`n=0`), 591 ist frisch rot gesehen, 589 bricht Commit 1 und
  `rev-list --count` fängt das.
- **`host-baum`-BEFUND:** Im sauberen Nachlauf tritt er nicht auf. Der Fall ändert nur die Kopie,
  das Erklärungsmuster des Implementers (parallele Änderung am Host) ist damit vereinbar.
- **Sensor-Doku:** `slice-mv.md` §Kanten und `full-smoke.md` beschreiben die neuen Wächter
  zutreffend. Ausnahme ist der Grenz-Absatz, siehe F-2.
- **§3.7 / Doc-Kommentare:** Beide Tests tragen einen eigenen Doc-Kommentar mit Zusage und
  Gegenbeispiel, ohne Chronik. Ausnahme ist F-1.
- **Plan-Abweichungen:** Der Träger aus DoD 1 ist die Go-Teststufe statt bats, begründet im
  Commit und in `slice-mv.md`, zugelassen durch den Plan. Sonst keine.
