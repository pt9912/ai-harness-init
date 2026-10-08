# Verifikation — slice-mv-kanten-nach-done-sind-bewacht

**Rolle:** Verifier (Modul 11) · **Datum:** 2026-10-08 · **Gegenstand:** Commits `7720b489` und
`a4bd8a40` gegen DoD und Plan des Slice `slice-mv-kanten-nach-done-sind-bewacht` (Welle
`welle-adopter-weg-im-ziel`) · **Eingang:** Review `2026-10-08-mv-kanten-review` (0 HIGH, 0 MEDIUM,
F-1/F-2 in `a4bd8a40` behoben, F-3/F-4 INFO) · **Bezug:** `LH-FA-01`, `LH-QA-01`, `AGENTS.md` §3.6.

## Verdikte je DoD-Punkt

- **DoD 1 — Wächter in `make gates` über beide Kanten: bestätigt.**
  `TestSliceMvEchtKanteOpenNachDone`/`…NextNachDone` (`cmd/ai-harness-init/slice_mv_kanten_echt_test.go`)
  fahren `harness/tools/slice-mv.sh` (`sliceMvSkript` = `../../harness/tools/slice-mv.sh`) als
  `bash`-Prozess mit Repo-Wurzel als Arbeitsverzeichnis, wie das Rezept `slice-mv` im `Makefile`.
  Gelesen: Exit 0, Commit-Zahl 3, Betreff `(reiner Move)` am vorletzten Commit, `numstat` exakt
  `0 0 {<from> => done}/slice-kante.md`, Positiv-Sonde *4 Links vorher*, 0 auf den alten / 4 auf den
  neuen Pfad (Quellen: Geschwister in beiden Formen, `done/`, `docs/reviews/`), ausgehendes Ziel
  umgeschrieben, Ist-Bestand von `<from>/` in beide Richtungen (Unterverzeichnis und ungetrackte
  Datei byte-gleich), `git status`, Zeile `eingehend: 3 … darin 1 praefixlose(r)` (Datei mit
  beiden Formen zählt einmal). In `make gates` über `test: test-bats test-go`. Träger ist die
  Go-Teststufe statt bats; der Plan lässt die Wahl ausdrücklich offen und verlangt Begründung —
  sie steht im Commit und in `harness/sensors/slice-mv.md`.
- **DoD 2 — `make full-smoke` fährt je Kante einen erfolgreichen Wechsel im Ziel: bestätigt.**
  Stufe `slice_mv_kanten_nach_done_im_ziel` (sprachloses Ziel): docs-check vor dem ersten Wechsel
  `0 Befund(e)`, je Kante `make slice-mv … TO=done` mit Exit 0 und Vollzugsmeldung, Datei allein
  in `done/`, vorletzter Commit reiner Rename, docs-check danach `0 Befund(e)`. Grün auf HEAD
  abgelesen in CI: `gh run view 37757328485` → `completed success`, Jobs `gates`, `smoke`,
  `full-smoke`, `adr-immutable` je `success`. Abdeckungs-Sicht: `make e2e-abdeckung` auf HEAD →
  rc=0, `git status --porcelain` leer (byte-gleich); Zeile `Stufe 21`, `full-smoke.sh:3593`, mit
  `NICHT gemessen`, deckungsgleich mit der GRENZE im Kopfkommentar.
- **DoD 3 — beide Wächter rot gesehen: bestätigt, Punkt 2 in stärkerer Form als geplant.**
  `make mutate MUTATE_CASES="589-… 590-… 591-…"` → `3 ok, 0 Befund(e)`, EXIT 0, kein `host-baum`:
  - `589 -> TestSliceMvEchtKanteOpenNachDone rot`, `590 -> TestSliceMvEchtKanteOpenNachDone rot`,
    `591 -> ein Verweis auf die bewegte Datei loest nicht auf rot` (130,20 s).
  - Ursache gelesen für 589 (fehlte im Review): `git archive HEAD` in den Scratchpad, Fall
    angewandt (`grep -c '(reiner Move)"$'` → 0), `make test-go` → beide Kanten-Tests rot mit
    *„erwartet … (3 Commits), sind 2"*, *„der vorletzte Commit ist nicht der reine Move:
    "Ausgangsstand""* und `numstat` mit Inhaltsänderungen statt `0 0`. Das ist die behauptete
    Ursache (Move und Nachzug in einem Commit). Ursache für 590 hat der Review gelesen, für 591 trägt
    das `expect`-Muster die Meldung selbst.
  - Plan-Text überholt: *„`make mutate` kennt für `make full-smoke` keine Fehlschlag-Form"*. Fall
    591 trägt `verify: full-smoke`, also gibt es die Form. Die Eigenschaft der DoD (ein Rot über
    einer gebrochenen emittierten Fassung, mit Kommando) ist erfüllt und dazu dauerhaft im Set.
- **`make gates` grün: bestätigt** — CI-Job `gates` auf `a4bd8a40` `success`; lokaler Lauf nach
  diesem Bericht siehe Commit.
- **Review: bestätigt** — Report liegt vor, anderer Kontext.
- **Doku-Update: bestätigt** — `slice-mv.md` §Kanten nennt die zwei Wächter (Zeile
  *„Zwei Wächter halten die zwei Kanten"*), den Grenz-Absatz zieht `a4bd8a40` nach;
  `full-smoke.md` nennt die Stufe.
- **Closure-Notiz, Register, Risiko-Ausgänge, Paarungen:** nicht Gegenstand — Planner-Arbeit
  (§7 und §6 stehen auf *offen bis zur Closure*). Reconciliation-Register: entfällt, wie deklariert.

## Plan-vs-Code

- **Plan → Code:** jede Zeile aus §3 hat ihr Gegenstück (Test, `full-smoke.sh`,
  `e2e-abdeckung.md`, drei Mutations-Fälle, zwei Sensor-Dateien). `Makefile` und Image unverändert.
- **Code → Plan:** nichts Gebautes ohne Plan. Fall 591 ist über DoD 3 hinaus (s. o.).
- **Überholte Plan-Annahmen:** §4 nennt als Rückführungs-Bedingung *„kein gepinntes Image trägt
  `git` und bats zugleich"*. Die Bedingung trat nicht ein, weil der Träger `go test` im Image der
  `test`-Stage ist, das `git` führt (`make test-go` grün, Tests nutzen `git`). Keine Rückführung
  fällig.

## Offene Punkte für den Planner

- **Risiko 1** (Fixture statt realer Quelle): Der Test fährt das Skript, das das Rezept fährt,
  byte-gleich kopiert; die Rezeptzeile selbst fährt er nicht (Review F-4). Ausgang entscheidet der
  Planner.
- **Risiko 2** (Laufzeit): Messwerte stehen im Umsetzungs-Commit (Paket 1,4 s; Fall 591 130 s
  hier). Ob das *merklich* ist, entscheidet der Planner.
- **Risiko 3:** nicht aus dem Diff entscheidbar.
- **INFO:** Fall 589 färbt zusätzlich den älteren `TestSliceMvEchtBrichtBeiGescheiterterErsetzungAb`
  rot; der Move-Commit war für eine andere Kante also schon bewacht. Der neue Test bindet ihn für
  die zwei Kanten; kein Befund.
- **INFO (Review F-3):** Die Teil-Zusagen *einmal zählen* und *Ist-Bestand Unterverzeichnis /
  ungetrackt* hält der Test, aber kein Fall unter `test/mutations/`. Die DoD verlangt keinen.

## Negativbefunde

- Zusage breiter als Sensor: keine gefunden. Die Deklaration der full-smoke-Stufe nennt, was sie
  nicht misst, und der Go-Test deckt genau diesen Rest am Dogfood-Werkzeug.
- Rot aus falscher Ursache: keines. 589 ist nachgelesen, 590/591 belegen Review und `expect`-Muster.
