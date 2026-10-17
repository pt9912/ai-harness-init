# Verifikation slice-golangci-lint-pin-folgt-dem-freshness-drift (HEAD f992b374)

Rolle Verifier. Frage: bauen wir es richtig, gegen Plan und DoD. Diff `d198c4c8^..d198c4c8` (Implementer): 3 Dateien, 4/4 Zeilen
(`Makefile` Z. 15, `Dockerfile` Z. 11 und 59, `internal/gen/golang.go` Z. 14) = Tabelle §3. Nicht im Diff: ADRs, `AGENTS.md`,
`harness/conventions*`, Slice-Datei, `.golangci.yml`. Haekchen, Closure, Register sind Planner-Arbeit (`AGENTS.md` §3.10).
Gebrochen in `git archive`-Kopien unter `~/.colima-tmp` (Image `--target test`, `docker run --network none`), Kopien und Images entfernt.

## Verdikte je DoD-Punkt

- **D1 Pin `v2.15.0` an jeder Stelle, belegter Digest: bestaetigt.**
  - `git grep -nE 'v?2\.14\.0' -- . ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done'`: nur der Slice-Plan (Z. 33, 91). `v2.15.0` in
    Makefile:15, Dockerfile:11 (ARG), Dockerfile:59 (Digest), `golang.go`:14.
  - `docker buildx imagetools inspect golangci/golangci-lint:v2.15.0` -> Index `sha256:fbfcfd12a6f8d7f1b97b3362ca80fc2a244d46863148c73cb88e7793af96c481` == Dockerfile:59.
    Der Tag `v2.14.0` liefert `sha256:ad862ba6...` (anderer Wert, der alte Digest ist ersetzt).
  - `make freshness-golangci`: `golangci-lint: aktuell — gepinnt und latest sind beide v2.15.0.` (Exit 0).
  - Rot-Beleg (selbst, an der realen Quelle in Kopien):
    - (a) `golangciVersion = "v2.14.0"` -> `TestGoProfile_PinsMatchRepo` rot: `gen_test.go:291: ARG GOLANGCI_LINT_VERSION: generiert "v2.14.0" != Repo-Dockerfile "v2.15.0" (Drift, LH-QA-02)`.
    - (b) Dockerfile `ARG GOLANGCI_LINT_VERSION=v2.14.0` (Digest unveraendert) -> rot: `generiert "v2.15.0" != Repo-Dockerfile "v2.14.0" (Drift, LH-QA-02)`.
    - (c) Makefile-Pin `?= v2.14.0`: `make -n gates | grep -c freshness` -> `0`; `make -n lint` reicht `GOLANGCI_LINT_VERSION=v2.14.0` als Build-Arg durch, kein Gate vergleicht ihn.
      Nur `make freshness-golangci` (Netz, nicht in gates) faerbt. Der Slice sagt das: §3 „Welcher Waechter koppelt welche Stelle“, §2 D1 nennt als Rot-Quelle `make freshness-golangci`. Nicht als gedeckt zugesagt.
      Messgrenze: `make -n` in der `.git`-losen Kopie, kein voller `make gates` mit gebrochenem Makefile-Pin.
    - (d) Falscher, real existierender Digest: nicht gebrochen gefahren; der Slice fuehrt die Luecke ohnehin als `BEO-ALL/pin-digest-ohne-waechter` (§1, §3, §6). Kein Test liest den Digest.
- **D2 `make lint` ohne Befund und ohne Suppression: bestaetigt.** `make lint`: Zeile `0 issues.` (selbst gelesen, nicht nur Exit). `git diff d198c4c8^ d198c4c8`: 0 Treffer `nolint`;
  `git diff ... -- .golangci.yml` leer.
- **`make gates` gruen: bestaetigt.** `make gates` Exit 0 auf HEAD f992b374; `.harness/state/gates-passed.head` == HEAD. Im Lauf: `baseline-verify: v6.18.1 OK`,
  `d-check: 2756 Datei(en) geprueft, 0 Befund(e)`, golangci `0 issues.`, bats- und Go-Tests ok (alle Pakete `ok`), `comment-claims 0 Befund(e)`,
  `register-ausgang 0 Befund(e)`, `mutate-greift: 653 Fall/Faelle, 653 greifen`, shellcheck/actionlint/`span-check` gelaufen. Zusaetzlich `make build` und `make test` als Teil von gates.
- **Zusatz `make full-smoke-host`: Exit 0.** Das emittierte Go-Skelett nutzt den Pin im Ziel: `FROM docker.io/golangci/golangci-lint:v2.15.0@sha256:fbfcfd12...` und `0 issues.` in den Ziel-Laeufen.
  Das ist ein Laufbeleg des Pins im Ziel (Host-Binary mit neuem `golangciVersion`), kein Release.
- Kein Release, kein Tag, kein Push im Slice (nur Implementer-/Reviewer-Commits seit `7e461a86`).
- Review-Report liegt vor (`f992b374`, 0 HIGH/0 MEDIUM/0 LOW/1 INFO). Closure-Notiz, Register, Risiko-Ausgaenge, Paarungen: nicht Gegenstand der Verifikation, stehen aus.

## Was `TestGoProfile_PinsMatchRepo` deckt und was nicht

- Deckt: Gleichheit `golangciVersion` (Emission) gegen `ARG GOLANGCI_LINT_VERSION` im realen Repo-Dockerfile, beide Richtungen rot gesehen.
- Deckt nicht: Makefile-Pin (nur `freshness-golangci`), den `@sha256`-Digest (kein Waechter), und dass `latest` aktuell ist (Netz).

## Plan-vs-Code

- Beide Richtungen: jede Zeile aus §3 im Diff, nichts im Diff ohne Plan. Dockerfile mit 2 Zeilen (ARG und Digest). Commit-Message nennt das Digest-Kommando und den Release-Ausschluss.
- Keine Norm-Artefakte, keine Slice-Datei im Implementer-Commit.

## Nicht belegt

- CI auf anderem Host: erst der naechste Push bzw. der Nacht-`upstream-drift`; lokal ist `make freshness-golangci` gruen, nicht der CI-Lauf.
- Mutations-Probe (`make mutate-auswahl` -> CI-Branch, make Exit 2 mit „Fehler 10“) nicht gefahren, kein Push; kein Fall fuer diesen Slice in `test/mutations/`.
- Kein Waechter fuer den Dockerfile-Digest und den Makefile-Pin im Gate (benannte Luecke); Rot-Beleg (d) nicht gemessen.

## Befunde

- Keine HIGH/MEDIUM-Befunde. DoD-Punkte 1, 2 und `make gates` bestaetigt. Offen fuer den Planner: Closure-Notiz mit Release-Hinweis (Emission erst mit dem naechsten Release),
  Register-Beleg fuer `pin-digest-ohne-waechter`, Trigger-Audit zu `pin-sprung-feuert-adr-trigger-ohne-nennung`.
