# ADR-0003: Implementierungssprache Go + native-Binary-Distribution

**Status:** Accepted

**Datum:** 2026-06-13

**Autor:** Demo

**Bezug:** [`LH-QA-03`](../../../spec/lastenheft.md), [`LH-QA-04`](../../../spec/lastenheft.md), [`LH-QA-02`](../../../spec/lastenheft.md)

**Schärft:** [architecture.md §3 Externe Abhängigkeiten](../../../spec/architecture.md) — Implementierungssprache, Build-Model, Distribution.

**Supersedes:** [ADR-0002](0002-test-tooling-grenze.md) (bats/bash-Toolchain — durch Go-Toolchain ersetzt).

---

## Kontext

Die Cross-Platform-Frage (Windows/macOS) machte die bash-Implementierung
fragil: macOS liefert default nur bash 3.2, natives Windows hat kein bash
(nur WSL2/Git-Bash mit Pfad-Mangling beim `docker run -v`). `LH-QA-03`
verlangt aber „grünes Repo out-of-the-box" plattformübergreifend. Ein
natives, statisch gelinktes Binary löst das ohne Host-Sprachlaufzeit.

Damit entfällt die in `ADR-0002` getroffene bats/shellcheck-Grenze: die
Toolchain wird Go (`go test`, `golangci-lint`), nicht mehr bash. `ADR-0002`
wird daher abgelöst.

## Entscheidung

Wir implementieren `ai-harness-init` in **Go** und liefern es als **native
Binaries** je `GOOS`/`GOARCH` (linux/macos/windows × amd64/arm64) aus
(GoReleaser-Stil). Der **Build** erfolgt **Docker-only**: Cross-Compile im
gepinnten Build-Image, **kein Host-`go`** — analog zur make/Docker-only-Disziplin
des Schwester-Repos d-check. Ein eigenes OCI-Image als *Vertriebsmittel*
entfällt (das Tool ruft selbst `docker` → Docker-in-Docker wäre unnötige Reibung;
native Binaries sind bereits plattformübergreifend).

## Verglichene Alternativen

### Option A — bash beibehalten

- Pro: kein Reset; Skript-Einfachheit für ein Datei-/Prozess-Tool.
- Contra: macOS bash 3.2, kein natives Windows; WSL2-Zwang; bricht die Cross-Platform-Zusage.

### Option B — Go + eigenes OCI-Image als Primärkanal

- Pro: reproduzierbar, bündelt Toolchain.
- Contra: Tool ruft selbst `docker` → Docker-in-Docker / Socket-Mount + Repo-Mount; löst kein Cross-Platform-Problem, das native Binaries nicht schon lösen.

### Option C — Go + native Binaries (gewählt)

- Pro: ein statisches Binary je Plattform, keine Host-Sprachlaufzeit; Docker-only-Build hält die Reproduzierbarkeit (`LH-QA-02`); kein DinD.
- Contra: Multi-OS/Arch-Build-Pipeline; Dev-/CI-Image muss Go-Toolchain + `golangci-lint` mitbringen.

## Konsequenzen

- Positiv: `LH-QA-04`-Plattform-Matrix erfüllbar; `LH-QA-03` ohne Host-Toolchain; konsistent zur Build-Familie (d-check).
- Negativ: Build-Image + GoReleaser-Pipeline nötig; `slice-001`..`slice-005` brauchen Neuzuschnitt (Go-Gates statt shellcheck/bats).
- Folgepflicht: CR an `LH-QA-03`/`LH-QA-04` (erfolgt, Lastenheft v0.2.0); `ADR-0002` auf Superseded; Durchsetzungsschicht (Hooks/`CLAUDE.md`) und Go-Toolchain-Gates adoptieren; Picker bleibt sprach-agnostisch (inkl. `cpp`).

## Fitness Function

| Tooling | Regel | Make-Target |
|---|---|---|
| golangci-lint | Lint-clean, keine Inline-`//nolint` ohne zentralen Eintrag | `make lint` *(folgt)* |
| go test | Tests grün im gepinnten Image | `make test` *(folgt)* |
| go build | Cross-Compile je `GOOS`/`GOARCH` im Image, kein Host-`go` | `make build` *(folgt)* |

## Re-Evaluierungs-Trigger

Wenn ein air-gapped/registry-freier Vertrieb zur Pflicht wird (kein
Docker-Pull beim Build) → Build-Model neu bewerten.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-06-13 | Accepted; supersedes [ADR-0002](0002-test-tooling-grenze.md) | `LH-QA-03`, `LH-QA-04` (Lastenheft v0.2.0) |
