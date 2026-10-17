# Verifikation slice-go-toolchain-pin-folgt-dem-freshness-drift (HEAD 71aa5eec)

Rolle Verifier. Frage: bauen wir es richtig, gegen Plan und DoD. Diff `dfc0dee1..ca2dd354` (Implementer): 5 Dateien, 6/6 Zeilen
(`Makefile`, `Dockerfile`, `internal/gen/golang.go`, `harness/tools/smoke.sh`, `full-smoke.sh`) = Tabelle §3. Nicht im Diff: ADRs, `AGENTS.md`,
`harness/conventions*`, Slice-Datei, `go.mod`. Geprueft ist die DoD vor Closure; Haekchen, Closure, Register sind Planner-Arbeit (`AGENTS.md` §3.10).
Gebrochen in `git archive`-Kopien unter `~/.colima-tmp` (Image `--target test`, `docker run --network none`), Kopien und Images am Ende entfernt.

## Verdikte je DoD-Punkt

- **D1 Pin `1.27.2` an jeder Stelle, belegter Digest — erfuellt.**
  - `git grep -nE '1\.27\.1' -- . ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done'`: nur Slice-Plan und die datierte Prosa
    `MR-092` Z. 33. `1.27.2` steht in Makefile:14, Dockerfile:10 und :14 (Digest), `golang.go`:11, `smoke.sh`:27, `full-smoke.sh`:156; `go.mod` `go 1.27` unveraendert.
  - Digest: `docker buildx imagetools inspect golang:1.27.2` -> Index `sha256:820153096fda4de6ac1b7194d12e416b7dd8f4e9a33d17e0345b111b945162d8`
    == Dockerfile:14. Der Tag `1.27.1` liefert `sha256:162be529...` (anderer Wert).
  - `make freshness-go`: `go-toolchain: aktuell — gepinnt und latest sind beide 1.27.2.`
  - Rot-Beleg Makefile-Pin (selbst): Kopie mit `GO_VERSION ?= 1.27.1` -> `make freshness-go`: `gepinnt: 1.27.1 / latest: 1.27.2`, Make-Fehler.
- **D2 Skelett traegt `1.27.2`, gekoppelt — erfuellt.**
  - (a) `DefaultGoVersion = "1.27.1"` in Kopie -> `TestGoProfile_PinsMatchRepo` rot: `ARG GO_VERSION: generiert "1.27.1" != Repo-Dockerfile "1.27.2" (Drift, LH-QA-02)`.
  - (b) Dockerfile `ARG GO_VERSION=1.27.1` -> rot: `generiert "1.27.2" != Repo-Dockerfile "1.27.1"`. Beide Male die behauptete Ursache, an der realen Quelle gebrochen.
  - Kein Release, kein Tag, kein Push im Slice (`git log`: nur Implementer-/Reviewer-Commits).
- **D3 `make build`/`test`/`gates` unter dem neuen Image ohne Befund — erfuellt.** `make gates` Exit 0 auf HEAD 71aa5eec; Stempel
  `.harness/state/gates-passed.head` == HEAD. Im Lauf: `baseline-verify OK`, `d-check: 2753 Datei(en) geprueft, 0 Befund(e)`, golangci `0 issues.`,
  bats-/Go-Tests gruen, `span-check` ok. Kein `//nolint` im Diff, `.golangci.yml` unberuehrt.
- **`make gates` gruen — erfuellt** (s. D3). Zusaetzlich `make full-smoke-host` Exit 0: Build-Arg `GO_VERSION=1.27.2`, Base `golang:1.27.2@sha256:8201...`, alle Stufen `OK`.
- Review-Report liegt vor (`71aa5eec`, 0 HIGH/0 MEDIUM/0 LOW/1 INFO). Closure-Notiz, Register, Risiko-Ausgaenge, Paarungen: nicht Gegenstand der Verifikation, stehen aus.

## Gezielte Lueckenpruefung (Zusage nicht breiter als Sensor)

- **Makefile-Pin faerbt `make gates` nicht (selbst belegt).** In der Kopie mit `GO_VERSION ?= 1.27.1`: `make test` laeuft durch alle Go-Tests; der einzige
  rote bats-Fall (`driver: die Kopie traegt den Sensor-Bedarf inklusive .git`) ist ein Artefakt der `.git`-losen Archiv-Kopie, kein Pin-Bezug.
  Nur `make freshness-go` (Netz, nicht in gates) faerbt. Der Slice benennt das: §3 „Welcher Waechter koppelt welche Stelle“ (Makefile-Pin: nur `freshness-go`),
  §2 D1 nennt als Rot-Quelle `make freshness-go`. Nicht als gedeckt zugesagt. Grenze meiner Messung: `make test` in der Kopie, nicht der volle `make gates`.
- **Falscher, real existierender Digest faerbt nichts (selbst belegt).** Kopie mit dem Digest von `golang:1.27.1` bei Tag 1.27.2: Image baut,
  `TestGoProfile_PinsMatchRepo` gruen. Der Slice fuehrt die Luecke: §1 (kein Sensor fuer Digest/Fallbacks, Folge-Slice
  `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`), §3, §6 -> `BEO-ALL/pin-digest-ohne-waechter`. Die Fallbacks in `smoke.sh`/`full-smoke.sh` sind ebenso ungedeckt und so benannt.

## Plan-vs-Code

- Beide Richtungen: jede Zeile aus §3 ist im Diff, nichts im Diff ohne Plan. Die Commit-Message nennt das Digest-Kommando (Plan-Pflicht §3) und den Release-Ausschluss.
- Keine Norm-Artefakte, keine Slice-Datei im Implementer-Commit.

## Nicht belegt

- CI-Lauf auf anderem Host: erst der naechste Push bzw. der Nacht-`upstream-drift`; `make freshness-go` ist lokal gruen, nicht der CI-Lauf.
- Mutations-Faelle (`make mutate`) nicht gefahren; fuer diesen Slice ist kein Fall in `test/mutations/` angelegt.
- Kein Waechter fuer den Dockerfile-Digest und die zwei Fallbacks (benannte Luecke, s. o.).
- Der Makefile-Rot-Beleg erfasst nicht den vollen `make gates` in der Kopie.

## Befunde

- Keine HIGH/MEDIUM-Befunde. DoD-Punkte 1-3 erfuellt. Offen fuer den Planner: Closure-Notiz mit Release-Hinweis, Register-Beleg fuer
  `pin-digest-ohne-waechter`, Trigger-Audit zu `pin-sprung-feuert-adr-trigger-ohne-nennung` (`MR-092`/`MR-093` nennen `1.27.2` datiert).
