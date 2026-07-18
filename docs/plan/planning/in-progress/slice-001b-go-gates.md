# Slice slice-001b: Go-Gates build/lint + Promotion

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem die Datei liegt
(`open/` · `next/` · `in-progress/` · `done/`), Wechsel nur per `git mv` —
v3.1.0-Konvention (`modul-05`).

**Welle:** [welle-01-offline-kern](../welle-01-offline-kern.md).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md).

**Autor:** Claude (Re-Slice 2026-07-18 — zweite Hälfte des zerlegten slice-001; erste Hälfte:
slice-001a Go-Skeleton + go-test).

---

## 1. Ziel

Die verbleibenden **Go-Gates** `build` (Cross-Compile des Binaries) und `lint` (golangci-lint)
real anlegen — als Dockerfile-Stages (a-check-Muster, `docker build --target`), ins `gates`-Target
aufgenommen und in AGENTS.md §4 + harness/README.md §Sensors aus „Nicht behauptet" **promotet**.
Vervollständigt die Fitness Function aus [`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md) (Docker-only Cross-Compile, golangci-lint,
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).

## 2. Definition of Done

- [ ] `make build` cross-compiliert `cmd/ai-harness-init` in der Dockerfile-`build`-Stage im
      **digest-gepinnten** Go-Image ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); **kein Host-`go`**.
- [ ] `make lint` (golangci-lint in gepinntem Image, Dockerfile-`lint`-Stage) grün, **keine
      Inline-Suppression** (Hard Rule 3.2); `.golangci.yml` trägt die zentrale Lint-Config
      (Suppressions nur dort, begründet).
- [ ] `build`/`lint` sind im `Makefile` angelegt **und im selben Commit** ins `gates`-Target
      aufgenommen sowie in [`AGENTS.md`](../../../../AGENTS.md) §4 + [`harness/README.md`](../../../../harness/README.md) §Sensors aus
      „Nicht behauptet" promotet — Promotion **erst nach lauffähigem, grünem Target**, nie davor
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), Hard Rule 3.1).
- [ ] `make gates` grün auf frischem Checkout ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Smoke).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Dockerfile` | update | `compile`/`lint`/`build`-Stages ergänzen (die `test`-Stage steht aus slice-001a) |
| `.golangci.yml` | neu | Lint-Config (zentrale Suppressions statt inline, Hard Rule 3.2) |
| `Makefile` | update | `build`/`lint` (`docker build --target`, `GOLANGCI_LINT_VERSION` build-arg) neu; beide ins `gates`-Target |
| [`AGENTS.md`](../../../../AGENTS.md) §4, [`harness/README.md`](../../../../harness/README.md) §Sensors | update | Promotion `build`/`lint` aus „Nicht behauptet" |

## 4. Trigger

**slice-001a in `done/`** (das Dockerfile + `go.mod` + Go-Code müssen existieren, bevor
`build`/`lint` etwas zu bauen/linten haben). Vorher wäre `build`/`lint` ein Gate über leerem
Prüfbereich. Rückführungen: `in-progress→next`/`→open` bei Größe/Blocker.

## 5. Closure-Trigger

DoD vollständig + Review konform + Verifier bestätigt + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **golangci-lint-Version + Base pinnen ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).** a-check spiegeln:
  `GOLANGCI_LINT_VERSION` als build-arg (**v2.12.2** wie a-check), Base digest-gepinnt. Der
  `golangci-lint`-Aufruf lebt im **Dockerfile** (RUN), nicht im Bash-Command → der PreToolUse-Guard
  (der das Literal blockt) greift nicht, weil er nur Bash scannt.
- **Promotion-Reihenfolge (halluziniertes Gate, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).** `build`/`lint` werden
  **erst** in AGENTS §4 / README §Sensors aus „Nicht behauptet" gehoben, **nachdem** das Target
  real grün läuft — nie umgekehrt.
- **Go-Gate-Home ist das Makefile, nicht `d-check.mk`** ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)) — Go-Gates sind
  Dogfood-Gates, d-checks Fragment bleibt unberührt (geklärte Alt-Plan-Drift).
- **`lint` kollidiert nicht mit `shell-lint`** — golangci-lint (Go) vs. shellcheck (bash), getrennte
  Targets.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `Makefile`/Gate-Config,
`Dockerfile` und die Doku teilen die adoptierte Harness-Mechanik; neues Repo, Spec führt, Code
folgt (`*` → Greenfield).
