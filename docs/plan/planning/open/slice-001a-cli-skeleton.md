# Slice slice-001: CLI-Skeleton (Go) + Go-Gate-Promotion

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem die Datei liegt
(`open/` · `next/` · `in-progress/` · `done/`), Wechsel nur per `git mv` —
v3.1.0-Konvention (`modul-05`).

**Welle:** [welle-01-offline-kern](../welle-01-offline-kern.md).

**Bezug:** [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md).

**Autor:** Demo. **Datum:** 2026-06-13. **Neuzuschnitt auf Go:** 2026-07-17 (slice-013-Lehre
angewandt: Ist-Zustand gegen die Accepted [`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md) gemessen — der Slice
plante einen bash-CLI mit `bin/`/shellcheck/bats, was der Go-native-Entscheidung
widerspricht. Auf `cmd/`-Go-Binary + Go-Gates gezogen).

---

## 1. Ziel

Ein lauffähiges natives **Go-Binary** `cmd/ai-harness-init` mit Arg-Parser und
korrekten Fehlerpfaden — und die dazugehörigen **Go-Gates** (`build`, `lint`, `test`)
real angelegt und in AGENTS.md §4 + harness/README.md §Sensors aus „Nicht behauptet"
promotet. Erfüllt die Fitness Function aus [`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md):
Build cross-compiliert **Docker-only** im gepinnten Image (**kein Host-`go`**,
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten); der
PreToolUse-Guard erzwingt das ohnehin), Lint via `golangci-lint`, Unit-Tests via Go.

## 2. Definition of Done

- [ ] [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) Negative-AC: fehlendes `--lang` → Exit 2 + Usage auf stderr (Go-Unit-Test).
- [ ] [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) Boundary-Teil: `--help`/`-h` → Exit 0 + Usage auf stdout (Go-Unit-Test).
- [ ] `--lang`, `--name`, `--force` werden geparst; unbekanntes Flag → Exit 2 + Usage.
      Bootstrap-Wirkung folgt in slice-002/003 (hier Stub: Exit 0 mit „noch nicht
      implementiert").
- [ ] `make build` cross-compiliert `cmd/ai-harness-init` im **gepinnten Build-Image**
      (Digest in `harness.mk`, [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); kein Host-`go`.
- [ ] `make lint` (golangci-lint im gepinnten Image) grün, keine Inline-Suppression
      (Hard Rule 3.2, [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- [ ] `make test` grün: die neuen Go-Unit-Tests **plus** die bestehende bats-Suite
      (Harness-Shell-Tooling). Beide unter demselben Target — die bats-Tests bleiben
      (sie prüfen die bash+awk-Hooks, [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)), Go-Tests kommen dazu.
- [ ] `make build`/`make lint` sind im Makefile angelegt **und im selben Commit** ins
      `gates`-Target aufgenommen sowie in [`AGENTS.md`](../../../../AGENTS.md) §4 +
      [`harness/README.md`](../../../../harness/README.md) §Sensors aus „Nicht behauptet"
      promotet — Promotion **erst nach lauffähigem Target**, nie davor
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), Hard Rule 3.1).
- [ ] `make gates` grün auf frischem Checkout ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Smoke).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `cmd/ai-harness-init/main.go` | neu | Arg-Parser, Usage, Exit-Codes; Bootstrap-Schritte als Stubs |
| `cmd/ai-harness-init/main_test.go` | neu | Negative-/Boundary-AC von [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) als Go-Test |
| `go.mod` | neu | Modul-Definition (Go-Version fixiert, [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) |
| `Makefile` / `harness.mk` | update | `build`/`lint` (Go-Toolchain-Image, digest-gepinnt) neu; `test` um Go-Unit-Tests erweitert; `build`/`lint` in `gates` |
| `.golangci.yml` | neu | Lint-Config (zentrale Suppressions statt inline, Hard Rule 3.2) |
| [`AGENTS.md`](../../../../AGENTS.md) §4, [`harness/README.md`](../../../../harness/README.md) §Sensors | update | Promotion `build`/`lint` aus „Nicht behauptet" |

## 4. Trigger

Welle-01 in-progress (erste Slice der Welle, keine Vorbedingung außer Bootstrap done).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz geschrieben → nach `done/`.

## 6. Risiken und offene Punkte

- **Go-Toolchain-Image ist zu pinnen (Impl-Entscheidung, [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).**
  `build`/`lint` laufen im gepinnten Image (Go-Toolchain + `golangci-lint`), Digest in
  `harness.mk` neben `BATS_IMAGE`/`SHELLCHECK_IMAGE`. Welches Image/welcher Digest ist
  bei der Umsetzung zu wählen und zu belegen — konsistent zur Docker-only-Linie
  ([`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md); Schwester-Repo d-check als Vorbild).
- **`make test` wird zum Aggregat.** Es deckt heute die bats-Suite; künftig zusätzlich
  die Go-Unit-Tests. Die bats bleiben (Harness-Shell-Tooling, [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)/[`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung));
  `shell-lint` (shellcheck) bleibt getrennt. `lint` (golangci-lint) ist **neu** und
  kollidiert nicht mit `shell-lint`.
- **Promotion-Reihenfolge (halluziniertes Gate, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).** `build`/`lint`
  werden **erst** in AGENTS §4 / README §Sensors aus „Nicht behauptet" gehoben, **nachdem**
  das Target real grün läuft — nie umgekehrt. Der Stop-Hook/Nachweis deckt das ab.
- **Kein Host-`go`.** Der PreToolUse-Guard blockt Host-Go-Toolchain (`go`/`gofmt`/`golangci-lint`,
  [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)) — der Build ist Docker-only, das ist erzwungen, nicht nur konvention.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example); neues Repo,
Spec führt, Code folgt — entspricht `harness/conventions.md` §Modus-Deklaration
(`*` → Greenfield).
