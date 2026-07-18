# Slice slice-001a: CLI-Skeleton (Go) + go-test-Gate

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem die Datei liegt
(`open/` · `next/` · `in-progress/` · `done/`), Wechsel nur per `git mv` —
v3.1.0-Konvention (`modul-05`).

**Welle:** [welle-01-offline-kern](../welle-01-offline-kern.md).

**Bezug:** [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md).

**Autor:** Demo (2026-06-13, Go-Zuschnitt 2026-07-17) · **Re-Slice 2026-07-18:** slice-001 war zu
groß (Modul 5) und wurde in **slice-001a** (dieser: Go-Skeleton + go-test) und **slice-001b**
(build/lint-Gates + Promotion) zerlegt.

---

## 1. Ziel

Ein lauffähiges natives **Go-Binary** `cmd/ai-harness-init` mit Arg-Parser und korrekten
Fehlerpfaden, **testbar** über ein `go test` im gepinnten Docker-Image (Dockerfile-`test`-Stage,
Muster: Schwester-Repo a-check). Erfüllt die Negative-/Boundary-AC von
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) und die Docker-only-Linie aus
[`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md) (**kein Host-`go`**, [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten); der PreToolUse-Guard erzwingt das).

**Abgrenzung:** die Gates `build` und `lint` (golangci-lint) + ihre Promotion in AGENTS §4 /
README §Sensors sind **slice-001b** — hier nur der go-**test**-Pfad. So bleibt der Schnitt in
einer Review-Sitzung prüfbar (Modul 5).

## 2. Definition of Done

- [ ] [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) Negative-AC: fehlendes `--lang` → Exit 2 + Usage auf stderr (Go-Unit-Test).
- [ ] [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) Boundary-Teil: `--help`/`-h` → Exit 0 + Usage auf stdout (Go-Unit-Test); `--lang`,
      `--name`, `--force` werden geparst, unbekanntes Flag → Exit 2 + Usage. Bootstrap-Wirkung
      folgt in slice-002/003 (hier Stub: Exit 0 mit „noch nicht implementiert").
- [ ] `make test` grün und deckt **beide**: die neuen Go-Unit-Tests (via Dockerfile-`test`-Stage,
      `docker build --target test` — die `go test`-Literale leben im Dockerfile, nicht im Bash-
      Command → guard-sicher) **plus** die bestehende bats-Suite (bleibt, prüft die bash+awk-Hooks,
      [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)/[`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)).
- [ ] Go-Toolchain-Base **digest-gepinnt** (a-check gespiegelt: `GO_VERSION` als build-arg, Base
      per `@sha256:`; [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); **kein Host-`go`**.
- [ ] `make gates` grün auf frischem Checkout ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Smoke).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `cmd/ai-harness-init/main.go` | neu | Arg-Parser, Usage, Exit-Codes; Bootstrap-Schritte als Stubs |
| `cmd/ai-harness-init/main_test.go` | neu | Negative-/Boundary-AC von [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) als Go-Test |
| `go.mod` | neu | Modul-Definition (Go-Version fixiert, [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) |
| `Dockerfile` | neu | Multi-Stage; hier die `test`-Stage (`go test`), Base digest-gepinnt (a-check-Muster). compile/lint/build-Stages folgen in slice-001b |
| `Makefile` | update | `test` läuft zusätzlich `docker build --target test` (go-test); `GO_VERSION` build-arg. **Kein** `d-check.mk` — Go-Gates leben im Makefile, nicht in d-checks Fragment |

## 4. Trigger

Welle-01 (erste Slice der Welle, keine Vorbedingung außer Bootstrap done). Rückführungen:
`in-progress→next` bei erneuter Größen-Erkenntnis; `in-progress→open` bei Blocker.

## 5. Closure-Trigger

DoD vollständig + Review konform + Verifier bestätigt + Closure-Notiz → nach `done/`. slice-001b
(build/lint) hängt dann an diesem `done/`-Zustand.

## 6. Risiken und offene Punkte

- **Go-Toolchain-Base wählen + pinnen (Impl-Entscheidung, [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).** Das Dockerfile
  spiegelt a-check: `FROM golang:$(GO_VERSION)` als build-arg, Base per `@sha256:` gepinnt
  (Digest bei der Umsetzung gegen das offizielle `golang`-Image zu belegen). **Go 1.26.4** wie
  a-check, sofern nichts dagegen spricht.
- **`make test` wird zum Aggregat.** Es deckt heute die bats-Suite; künftig zusätzlich die
  Go-Unit-Tests (Dockerfile-`test`-Stage). Die bats bleiben (Harness-Shell-Tooling,
  [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)); `shell-lint` (shellcheck) bleibt getrennt.
- **Go-Gate-Home ist das Makefile, nicht `d-check.mk`.** Die Go-Gates sind Dogfood-Gates (wie
  `test`/`shell-lint`) und leben im Makefile; sie treiben Dockerfile-Stages. d-checks Fragment
  (`d-check.mk`, [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)) bleibt unberührt — das war die geklärte Alt-Plan-Drift.
- **Kein Host-`go`.** Der PreToolUse-Guard blockt Host-Go-Toolchain
  ([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)); der `go test` läuft im Dockerfile — das ist erzwungen, nicht nur Konvention.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): neues Repo, Spec führt,
Code folgt — entspricht `harness/conventions.md` §Modus-Deklaration (`*` → Greenfield).
