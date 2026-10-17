# Review: slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor

Rolle Reviewer · Diff `76790d5a` (a: Fallback-Kopplung) und `30a9da96` (b: Digest-Achse) · Plan:
`slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor` (in-progress, §1–§3) · Bezug LH-QA-01,
LH-QA-02, ADR-0049 · geprüft gegen Plan, AGENTS.md §3.1/§3.2/§3.3/§3.5/§3.6/§3.7/§3.10, MR-071/MR-090,
`harness/sensors/mutate.md`, Baseline `modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin) — nicht
gegen die DoD (Verifier). DoD (c) ist nicht geliefert; geprüft ist nur die Aussage dazu (F-4).

## Summary

0 HIGH · 1 MEDIUM · 0 LOW · 4 INFO. (a) und die Vergleicher/Lese-Hälfte von (b) tragen, die
Brüche an der realen Quelle sind rot gesehen. Das MEDIUM: die Exit-Abbildung der Hauptschleife von
`digest-freshness.sh` (Exit 0/1/2, die Zusage in Skriptkopf und Index-Zeile) hält weder Test noch
Mutations-Fall. `make gates` grün, Stempel == HEAD (`30a9da96`).

## Findings

### F-1 MEDIUM — Exit-Abbildung der Hauptschleife von `digest-freshness.sh` ungebunden (stilles Grün möglich)

- `quelle`: AGENTS.md §3.6, LH-QA-02
- `pfad`: `harness/tools/digest-freshness.sh:105-121` (Schleife, `case "$rc"`, `exit "$fehler"`)
- `befund`: `test/digest-freshness.bats` ruft nur `--compare` und `--pins` auf; beide enden vor der
  Schleife. Gemessen auf einer Kopie mit PATH-Stub `docker` (liefert für jeden Tag `sha256:0…0`, alle
  fünf Pins weichen ab): unverändert Exit 1; mit `1) befund=1 ;;` → `1) : ;;` Exit 0; mit
  `exit "$fehler"` → `exit 0` bleibt auch ohne `docker` Exit 0. Eine Mutation, die den Nacht-Lauf bei
  falschem Digest oder Registry-Ausfall grün meldet, färbt keinen Test und keinen der Fälle 668–671.
  Die Zusage „Exit: 0 / 1 / 2" (Skriptkopf) und „Fehlschlag über `make`: Exit 2" (Index-Zeile) trägt
  damit allein der einmalige Handlauf. Der Weg ist hermetisch bindbar (der Stub oben).
- `verifizierbar`: ja (Kopie + Stub, Kommandos im Lauf-Protokoll)
- `klasse`: Zusage der Aggregat-Schleife eines Sensors ohne bindenden Fall, nur der Teil-Vergleicher gebunden

### F-2 INFO — Registry-Antwort 429 färbt den Nacht-Lauf, nie ein Grün

- `quelle`: Plan §6 (Registry-Ausfall darf keinen Push blockieren)
- `pfad`: `.github/workflows/upstream-drift.yml:67-71`, `harness/tools/digest-freshness.sh`
- `befund`: Während des Laufs antwortete Docker Hub anonym `429 Too Many Requests`; `make freshness-digest`
  endete mit `FETCH-FEHLER (kein Urteil)` je Hub-Pin und `make: *** [freshness-digest] Error 2` — kein
  stilles Grün, und der Befund 1 geht vor 2. Der Schritt steht im Muster der Nachbarn
  (`if: '!cancelled()'`), nur `upstream-drift.yml` ändert sich, `ci.yml` nicht. Ein Hub-Rate-Limit
  des Runners färbt den Nacht-Lauf ohne Digest-Defekt; Plan §6 nimmt das (Ausfall färbt nur Nachts) hin.
- `verifizierbar`: ja
- `klasse`: Netz-Sensor-Ausfall als Rot statt als Befund

### F-3 INFO — Fall 671 färbt drei Tests, bindet über eine gemeinsame Quelle

- `quelle`: Reviewer-Skill (Mutations-Fall nennt einen Test, die Mutation färbt mehrere)
- `pfad`: `test/mutations/671-digest-freshness-pin-quelle-verfehlt-das-dockerfile.sh`
- `befund`: Auf einer Kopie färbt die Mutation Test 4, 5 und 6 von `digest-freshness.bats` (alle lesen
  das reale `Dockerfile` über `--pins`); `# expect:` nennt Test 4. Der Kopf behauptet keine Exklusivität.
  Gemeinsame Quelle, kein Redundanz-Befund. 668 (nur Test 4 von `pin-fallbacks.bats`), 669 (nur Test 5)
  und 670 (nur Test 2) färben je allein ihren benannten Fall (nach Lesung der Mutation, nicht per
  `skip` gefahren).
- `verifizierbar`: ja
- `klasse`: gemeinsame Quell-Stelle färbt mehrere Tests

### F-4 INFO — Aussage zu (c) „mehr als eine benannte Abweichung je Paar" stimmt

- `quelle`: Plan §4 (Rückführ-Trigger `in-progress` → `next`)
- `pfad`: `harness/tools/history-range-guard.sh` / `internal/emit/templates/enforce/history-range-guard.sh`
  u. a.
- `befund`: `diff` der Paare, Kommentarzeilen und Zeilen-Endkommentare entfernt: `history-range-guard`
  zwei Abweichungen (Meldung `--decide-staged`/`--staged`; die Test-Einstiege `--decide`/`--decide-staged`
  samt Usage, 14 Diff-Zeilen), `stop-require-gates` eine (Pfad `harness/tools/` ↔ `tools/harness/`),
  `record-gates` zwei (Meldungsende „ADR-0083 Festlegung 4" und derselbe Pfad), `close-welle.md`
  `diff | wc -l` → 243. Der Trigger ist durch `history-range-guard` eingetreten. Der Schnitt ist
  Planner-Arbeit; `stop-require-gates` allein trüge nur eine Abweichung.
- `verifizierbar`: ja
- `klasse`: Zwei-Fassungen-Paar mit mehr als einer Abweichung

### F-5 INFO — Pin-Liste vollständig für tag-tragende Pins; digest-only-Pins benannt, DoD (b) wörtlich enger

- `quelle`: AGENTS.md §3.6, Plan DoD (b) (nur als Hinweis an den Verifier)
- `pfad`: `harness/tools/digest-freshness.sh:19-23`, `Makefile:8-10`
- `befund`: `git grep -n '@sha256' -- . ':!.harness/baseline' ':!docs' ':!test'` und
  `git grep -nE 'Digest *= *"sha256|DIGEST *\?= *sha256'`: Digest-Pins sind `Dockerfile` (2),
  `d-check.mk`, `internal/emit/emit.go`, `internal/emit/archgate.go` (alle fünf in der Liste) sowie
  `BATS_IMAGE`/`SHELLCHECK_IMAGE`/`ACTIONLINT_IMAGE` im Makefile und `curlimages/curl` in
  `tap-nachzug.sh`/`traeger-fetch.sh` (+ Vorlagen-Kopie `internal/emit/templates/enforce/traeger-fetch.sh`).
  Diese führen keinen Tag neben dem Digest (Makefile-Kommentar Z. 7 nennt keinen), die Begründung
  stimmt; Skriptkopf und Index-Zeile nennen die Grenze. Die Skelett-Dockerfiles führen keinen Digest
  (`@sha256` unter `internal/gen` nur im Kommentar `golang.go:937`). DoD (b) liest „jeder Image-Pin"; geliefert
  ist „jeder tag-tragende".
- `verifizierbar`: ja
- `klasse`: Pin-Liste mit benannter Grenze gegenüber Wortlaut der Zusage

## Negativbefund (geprüft, ohne Befund)

- **(1a) §3.6 an der realen Quelle, `pin-fallbacks.bats`:** der Test liest Makefile-Pin und beide
  Fallbacks aus den realen Dateien und vergleicht Wert gegen Wert. Bruch auf Kopie: Fallback in `smoke.sh`
  auf `1.27.1` → `not ok 4 … smoke.sh: Fallback '1.27.1' != Makefile GO_VERSION '1.27.2' (Pin-Zug ohne
  Fallback)`; in `full-smoke.sh` → `not ok 5 … full-smoke.sh: Fallback '1.27.1' != …`; Tests 1–3 bleiben ok
  (Zählung `genau einen` hält das Format fest). Gemessen ist die Eigenschaft, nicht die Implementierung.
- **(1b) `make freshness-digest`:** grüner Lauf für alle fünf Pins (ohne Hub-429, ungekürzt: `go-toolchain`,
  `golangci-lint`, `d-check`, `d-check-emit`, `a-check-emit` je `aktuell …`, Exit 0). Ein real
  existierender falscher Digest (der a-check-Digest in `d-check.mk` auf einer Kopie): `d-check: DIGEST
  WEICHT AB … tag: ghcr.io/pt9912/d-check:v0.86.1 / gepinnt: sha256:2368f7b3… (d-check.mk DCHECK_DIGEST) /
  aufgeloest: sha256:3e0b9779…`, Exit 1. DCHECK_DIGEST entfernt → `Pin 'd-check' nicht lesbar
  (d-check.mk DCHECK_DIGEST) — kein Urteil.`, Exit 2 (ebenso `Pin 'go-toolchain' nicht lesbar` bei
  gebrochenem Dockerfile-Digest-Format); Exit 2 ist kein stilles Grün, die übrigen Pins werden weiter geprüft.
  Der konkrete Digest `sha256:162be529…` am Tag 1.27.2 war wegen des Hub-429 nicht fahrbar (Digest in
  den Berichten nur gekürzt); ersatzweise der reale fremde Digest oben — **gelesen, nicht gefahren** für
  den golang-Pin.
- **(3) Zusage Skriptkopf/Index-Zeile:** `make freshness-digest` unter 429 → Exit 2 über `make`
  (`Error 2`), „kein Gate — nur nächtlich" deckt sich mit dem `## `-Hilfetext (`NICHT in gates`); Bindung
  `LH-QA-02`; Kommentare im Indikativ, Herkunft als ein `· seit slice-…`-Feld, keine Befund-Kennung (§3.7).
  `.d-check.yml`: 28 Namen in Gruppe (a) gezählt, 24 davon tragen `NICHT in gates` im Makefile-Hilfetext
  (`span-clean`, `doc-immutable`, `doc-commits`, `record-gates` nicht) → „24 von 28" stimmt.
- **(4) Workflow:** Form wie die Nachbar-Schritte; `make ci-lint` läuft in `make gates` grün; kein
  CI-Regime berührt (`ci.yml` unverändert, nur `upstream-drift.yml`).
- **(5) `digest-freshness.bats`:** hermetisch (`--network none`, nie Registry); der Kopf benennt, dass
  `--compare` nur den Vergleicher misst und der Registry-Lauf `make freshness-digest` ist. `--pins` liest
  die realen Dateien (Fall 4–6) — die Fixture-Verdeckung ist für die Lese-Hälfte vermieden; die Lücke der
  Hauptschleife steht in F-1.
- **(6) Mutations-Fälle 668–671:** `make mutate-greift` → `657 Fall/Faelle, 657 greifen, 0 Befund(e)`;
  `MUTATE_CASES=671-digest-freshness-pin-quelle-verfehlt-das-dockerfile make mutate` → `ok … -> --pins liest
  die fuenf realen Pin-Stellen mit Tag und Digest rot`, `1 ok, 0 Befund(e)`. Köpfe tragen Zusage/Kopplung,
  keine Chronik. 668/669 ändern den Wert mit generischem `[0-9.]*`-Anker (greift bei jedem Pin-Zug).
- **(7) Lint:** `[$]` statt `$` in den sed-Mustern ist in BRE ein literales Dollar und dieselbe Form, die
  38 bestehende Fälle unter `test/mutations/` führen — keine Suppression (`grep SC2016`-Kommentare im
  Bestand erklären die Form); `shell-lint`, `lint`, `docs-check` (targets, beide Richtungen) sind Teil von
  `make gates` → `EXIT 0`.
- **(8) Commit-Zuschnitt:** beide Commits nur Implementer-Artefakte (Skript, Tests, Fälle, Makefile,
  Workflow, README-Zeile, `.d-check.yml`); kein ADR, kein `AGENTS.md`, kein `harness/conventions*`, keine
  Closure-Notiz, kein Move; `git log origin/main..HEAD` nennt nur die Slice-Commits, kein Tag. Stempel
  `.harness/state/gates-passed.head` == HEAD `30a9da96`.
- **(9) `make mutate-auswahl`:** `SLICE=… make mutate-auswahl` → `56 Fall/Faelle ueber 0bd28b7b374d..HEAD
  (Schwelle 8 lokal)`, `CI-Branch — git push origin HEAD:refs/heads/mutate/…-30a9da96`, `Error 10`, Exit 2 über
  `make`; 668–671 stehen in der Auswahl. Kein Push gefahren: **nicht belegt** ist damit, dass die 56
  Fälle (einschließlich 668–671 im CI-Lauf) rot färben, der Workflow `mutate-branch.yml` auf diesem HEAD läuft
  und der Nacht-Lauf `upstream-drift.yml` den neuen Schritt unter echtem Runner (buildx, Hub-Rate-Limit) fährt.
  Einzeln gefahren ist nur Fall 671.
- **§3.3 / §3.5:** kein Move, keine Gate-Senkung; `freshness-digest` ist `kein Gate` und kein
  Gate-Versprechen (modul-13 „Vorhanden ≠ behauptet": die Zeile trägt die Marke in der Zelle selbst).
