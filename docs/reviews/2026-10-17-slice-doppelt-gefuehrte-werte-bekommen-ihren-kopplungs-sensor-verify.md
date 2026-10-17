# Verifikation slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor (HEAD b3bb759c)

Rolle Verifier. Frage: bauen wir es richtig, gegen Plan und DoD. Geprueft sind die Liefer-Punkte (a) und (b); (c) ist nicht
geliefert (Rueckfuehr-Trigger §4), bewertet wird nur die Aussage „Trigger eingetreten“. Implementer-Commits `76790d5a` (a),
`30a9da96` (b), Rueckfluss `084443f9`, `b3bb759c`; Reviewer-Report `76202836` (0 HIGH / 1 MEDIUM F-1, behoben / 4 INFO).
Messungen mit `PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH`; Brechen in einer Kopie unter `~/.colima-tmp`
(`git archive HEAD`), nie im committeten Baum; Kopie am Ende entfernt. Einziger laufender Agent.

## Verdikte je DoD-Punkt

- **(a) Fallbacks — erfuellt.**
  - Die Fallbacks `GO_VERSION="${GO_VERSION:-1.27.2}"` stehen in `smoke.sh:27` und `full-smoke.sh:156`; die Skripte sind
    unveraendert, gekoppelt wird per `test/pin-fallbacks.bats` (netzlos, liest Makefile, smoke.sh und full-smoke.sh selbst; laeuft in
    `make test`, damit in `make gates`). Plan §3 erlaubt „liest den Pin oder wird gegen ihn geprueft“.
  - **Rot an der realen Quelle (selbst, Pause nach `sed -i`):**
    - `smoke.sh`-Fallback auf `1.27.1`: `not ok 4 pin-fallbacks: GO_VERSION-Fallback in smoke.sh == Makefile-Pin (LH-QA-02)`,
      `# smoke.sh: Fallback '1.27.1' != Makefile GO_VERSION '1.27.2' (Pin-Zug ohne Fallback)`; 1-3 und 5 ok.
    - `full-smoke.sh`-Fallback auf `1.27.1`: `not ok 5 … full-smoke.sh …`, `# full-smoke.sh: Fallback '1.27.1' != Makefile GO_VERSION '1.27.2'`.
    - Makefile-Pin selbst auf `1.27.3`: `not ok 4` und `not ok 5` (`Fallback '1.27.2' != Makefile GO_VERSION '1.27.3'`).
    - Basis ohne Eingriff: 5 von 5 ok.
  - Mutations-Faelle 668/669 verankern denselben Bruch (`mutate-greift` greift).
- **(b) Digest — eingeschraenkt (Wortlaut „jeder Image-Pin“, geliefert „jeder tag-tragende Image-Pin“).**
  - Erfasst (`--pins`, 5 Stellen): golang- und golangci-lint-`FROM` im Dockerfile (Tag aus Makefile), `d-check.mk`
    `DCHECK_IMAGE`/`DCHECK_DIGEST`, `emit.go` `DefaultImage`/`DefaultDigest`, `archgate.go` `DefaultArchImage`/`DefaultArchDigest`.
  - Vollstaendigkeit selbst gemessen (`git grep '@sha256'` ohne Baseline/docs/test, `git grep 'Digest *= *"sha256'`): nicht erfasst
    sind `Makefile:8-10` (`BATS_IMAGE`, `SHELLCHECK_IMAGE`, `ACTIONLINT_IMAGE`: `name@sha256:` ohne Tag) sowie das curl-Image
    `curlimages/curl@sha256:463eaf60…` in `tap-nachzug.sh:66`, `traeger-fetch.sh:35` und der Vorlagen-Kopie
    `internal/emit/templates/enforce/traeger-fetch.sh:35`. Alle uebrigen Treffer sind Prosa, Test-Fixtures oder `*@sha256:*`-Formpruefungen.
    Die Aufzaehlung im Skriptkopf (GRENZE) stimmt mit dieser Messung ueberein.
  - Begruendung „kein Tag, gegen den der Digest zu halten waere“: stimmt fuer die Kopplungs-Frage (Tag und Digest als Paar);
    sie ist keine Aussage ueber die uebrigen Pins, die der Wortlaut „jeder“ mitmeint. Die Luecke gegenueber dem Wortlaut ist im
    Skriptkopf ehrlich benannt. Die Entscheidung ueber den DoD-Wortlaut trifft der Planner; mein Verdikt: **eingeschraenkt**, nicht „erfuellt“.
  - Nachtlauf, nicht in `make gates`: Makefile-Ziel `freshness-digest` („NICHT in gates“), Schritt in `upstream-drift.yml`; `ci.yml` unveraendert.
  - **Rot (selbst), Registry-Teil:** Der real existierende Bruch (Digest von `golang:1.27.1` an Tag `1.27.2`) ist **nicht fahrbar**:
    `docker buildx imagetools inspect golang:1.27.2 …` -> `429 Too Many Requests` (anonymes Docker-Hub-Limit), ebenso `golang:1.27.1`.
    `make freshness-digest` am echten Baum: `go-toolchain: FETCH-FEHLER (kein Urteil)`, `golangci-lint: FETCH-FEHLER`,
    drei Nicht-Hub-Pins `aktuell`, `make: *** [freshness-digest] Error 2`. Gefahren stattdessen die Nicht-Hub-Pins in der Kopie:
    - `archgate.go`-Digest letztes Zeichen `2` zu `3`: `a-check-emit: DIGEST WEICHT AB — der Digest gehoert nicht (mehr) zum Tag.`,
      `tag: ghcr.io/pt9912/a-check:v0.23.2`, `gepinnt: sha256:…f423  (internal/emit/archgate.go DefaultArchDigest)`,
      `aufgeloest: sha256:…f422`, `digest-freshness: mindestens ein Digest gehoert nicht zu seinem Tag.`, EXIT=1.
    - `d-check.mk`-Digest `…ce0e` zu `…ce0f`: `d-check: DIGEST WEICHT AB`, gepinnt `…ce0f  (d-check.mk DCHECK_DIGEST)`, aufgeloest `…ce0e`, EXIT=1.
    - `emit.go` `DefaultDigest`-Zeile entfernt: `digest-freshness: Pin 'd-check-emit' nicht lesbar (internal/emit/emit.go DefaultDigest) — kein Urteil.`, EXIT=2.
    - Dockerfile-golang-Digest entfernt: `Pin 'go-toolchain' nicht lesbar (Dockerfile FROM golang) — kein Urteil.`, EXIT=2.
    Die Positivrichtung gegen die Registry fuer golang und golangci-lint ist damit **unbelegt**; der Hub-Zweig ist nur ueber den
    Stub-Test und die Nicht-Hub-Pins gedeckt.

## Rot-Beleg der Hauptschleife (bats Fall 7-10, selbst, in der Kopie)

Basis: 10 von 10 ok.
- `1) befund=1 ;;` zu `1) : ;;`: `not ok 8 … ein Digest weicht ab -> exit 1` (`[ "$status" -eq 1 ]' failed`) und
  `not ok 10 … Abweichung und Fehlschlag zugleich -> exit 1 geht vor 2` — wie erwartet.
- `exit "$fehler"` zu `exit 0`: `not ok 9 … Aufloesung schlaegt fuer einen Pin fehl -> exit 2` (`[ "$status" -eq 2 ]' failed`) — wie erwartet.
- **Dritter Bruch (vom Implementer nicht gefahren)** `2) fehler=2 ;;` zu `2) : ;;`: `not ok 9 … Aufloesung schlaegt fuer einen Pin fehl -> exit 2`
  (`# (in test file test/digest-freshness.bats, line 106) [ "$status" -eq 2 ]' failed`); 7, 8, 10 ok. Der Bruch faerbt Fall 9; keine Luecke.
- Grenze: Fall 7-10 laufen ueber einen PATH-Stub `docker`; die Aufloesung gegen die Registry fuehrt allein `make freshness-digest`.

## Mutations-Faelle 668-673 (MR-071 und MR-090 gelesen)

- `make mutate-greift`: `mutate-greift: 659 Fall/Faelle, 659 greifen, 0 Befund(e)` — Anker treffen im Quellbestand.
- Form: `# files:` und `# expect:` vorhanden, `expect` ist je ein Teilstring eines Testnamens; Anker zitieren Wortlaut, keine
  Zeilennummern (MR-071 erfuellt); Nummern 668-673 fortlaufend nach 667. Anker 668/669 generisch (`[0-9.]*`), damit pin-zug-fest.
- **Einzelfall gefahren:** `MUTATE_CASES=672-digest-freshness-schleife-verliert-den-befund make mutate` ->
  `mutate: ok 672-… -> Hauptschleife, ein Digest weicht ab -> exit 1 rot`, `1 ok, 0 Befund(e)`, `TEILLAUF 1 von 659 — kein Beleg`.
  Der Grund ist die erwartete Meldung. Die uebrigen fuenf Faelle liefen nicht einzeln (Stichprobe); 673 entspricht dem Bruch `exit 0` oben.

## Index-Zeile `make freshness-digest` (harness/README.md)

- Die Zeile sagt „jedes tag-tragenden Image-Pins (Liste im Skriptkopf)“; Adjektiv und Zeiger tragen die Einschraenkung; „alle Pins“
  behauptet sie nicht. Zusagen ueber das Gilt hinaus: keine. Weniger Auskunft als mit dem entfallenen Halbsatz: die ausgenommenen Pins
  sind aus der Zeile nur ueber den Zeiger auf Prosa ablesbar. Bewertung: tragfaehig, aber duenn — INFO, kein Befund.
  „kein Gate — nur nächtlich“ steht in der Zeile.
- `make docs-check` gruen (Teil von `make gates`). Die Zahl „24 von 28“ im Kommentar der `.d-check.yml` habe ich nicht nachgezaehlt; kein Waechter haelt sie.

## upstream-drift.yml

- Schritt `make freshness-digest` mit `if: '!cancelled()'` nach dem Muster von `freshness-kotlin`; `make ci-lint` gruen (Teil von `make gates`).
- **Offenes Risiko (kein Urteil):** zwei Hub-Pins (golang, golangci-lint) werden anonym aufgeloest; ein 429 faerbt den Nacht-Lauf (Exit 2)
  auch ohne Digest-Defekt — lokal gemessen 429 fuer beide. Wie oft der GitHub-Runner limitiert wird, ist **ungemessen**; das
  Nacht-Signal kann dadurch verwaessern. Der Skriptkopf nennt es.

## Plan-vs-Code

- Diff `76790d5a~1..HEAD`: `.d-check.yml`, `upstream-drift.yml`, `Makefile`, `harness/README.md`, `digest-freshness.sh`, zwei bats-Dateien,
  sechs Mutations-Faelle; der Slice-Plan nur durch `slice-mv`-Moves. Kein ADR, keine AGENTS.md, kein `harness/conventions*`, keine Closure,
  kein `ci.yml`. DoD und §4 wurden nicht veraendert. Kein Push (`main` 11 Commits ahead), kein Tag.
- Gebautes ohne Plan: keines. Keine Lint-Suppression in den neuen oder geprueften Dateien (`git grep` auf `shellcheck disable` und `nolint` leer).

## (c) — die Aussage „Trigger eingetreten“ stimmt

Selbst gelesen (`diff` Dogfood gegen Vorlage unter `internal/emit/templates/`, Kommentarzeilen entfernt):
- `history-range-guard.sh`: zwei Code-Abweichungen — Meldungstext `--decide-staged` gegen `--staged` (Z. 34) und der Test-Haken-Block
  `--decide`/`--decide-staged` samt Usage-Zeile (Z. 43-55 gegen 43); 142 Diff-Zeilen inklusive Kommentare.
- `stop-require-gates.sh`: eine (Pfad `harness/tools/` gegen `tools/harness/`, Z. 53). `record-gates.sh`: zwei (Meldungstext mit
  `ADR-0083`-Verweis, Z. 17; Pfad, Z. 22). `close-welle.md`: 224 Diff-Zeilen, durchgehend umformuliert.
- §4 verlangt „mehr als eine benannte Abweichung“ je Paar: erfuellt von history-range-guard, record-gates und close-welle. Der Trigger ist
  eingetreten. (c) selbst wird nicht bewertet.

## Sensoren

- `make gates` Exit 0 auf HEAD `b3bb759c` (allein gefahren; enthaelt lint, shell-lint, ci-lint, docs-check, test, build, mutate-greift);
  `.harness/state/gates-passed.head` == `b3bb759cc7b083e69a7ba5e7547eb23853757ecd` == `git rev-parse HEAD`.
- `make lint` und `make shell-lint` nicht einzeln gefahren, nur als Teil von `make gates`.

## Nicht belegt / offen fuer den Planner

- Der neue Nachtschritt wirkt erst nach Push; nie gegen den GitHub-Runner gelaufen.
- Registry-Positivrichtung fuer die Hub-Pins (Digest von `golang:1.27.1` an `1.27.2`) wegen 429 nicht gefahren; Haeufigkeit des Hub-Limits ungemessen.
- (b) ist gegenueber „jeder Image-Pin“ eingeschraenkt (digest-only: bats, shellcheck, actionlint, curl dreifach) — Planner entscheidet
  Wortlaut oder Folge-Slice. Der curl-Digest ist laut vorhandenen Tests und Mutations-Fall 417 anderweitig gekoppelt (nicht im Detail geprueft).
- `make mutate-auswahl` (CI-Branch-Urteil) nicht gefahren; nur Fall 672 einzeln.
- (c) ist neu zu schneiden (Planner); Closure-Notiz, Register und Haekchen sind Planner-Arbeit.
