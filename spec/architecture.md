# Architektur — ai-harness-init

**Status:** Aktiv. **Letzte Änderung:** 2026-06-13.

**Hard Rule:** sprach- und meilensteinfrei — keine Wellen, Slices oder
Commit-Hashes. Die zeitliche Schicht lebt in docs/plan/planning/ *(folgt)*.

---

## 1. Komponenten-Übersicht

```mermaid
flowchart TB
    CLI[CLI / Arg-Parser]
    Fetch[Template- und Skelett-Fetcher]
    Place[Zweiklassige Ablage]
    Gate[Gate-Baseline-Emitter]
    Pick[Sprachskelett-Picker]
    CLI --> Fetch
    Fetch --> Place
    Fetch --> Pick
    Place --> Gate
```

## 2. Schichten und Constraints

| Schicht | Verantwortung | Darf NICHT |
|---|---|---|
| CLI | Arg-Parsing, Orchestrierung | Dateiinhalte erfinden |
| Fetcher | Templates/Skelett vom gepinnten Tag holen | floating main nutzen |
| Placer | Templates zweiklassig ablegen | Set-Index-README kopieren |
| Emitter | Gate-Baseline schreiben | Gate ohne existierendes Target aktivieren |
| Picker | Sprachskelett verdrahten | nicht-laufende Targets emittieren |

## 3. Externe Abhängigkeiten

| System | Rolle | Substituierbar |
|---|---|---|
| git | Repo-Init/Checkout | nein |
| docker | d-check-Image-Lauf (Gate) + Tool-Build-Image | nein |
| Go-Toolchain (im gepinnten Build-Image) | Tool-Build / Cross-Compile, Docker-only | nein |
| Kurs-Release (gepinnt) | Templates + Sprachskelette (`go`/`python`/`kotlin`/`java`/`csharp`/`cpp`) | Tag wählbar |

> Implementierung: **Go**; Auslieferung als **native Binaries** je `GOOS`/`GOARCH`,
> cross-kompiliert im gepinnten Build-Image (Docker-only, kein Host-`go`).

## 4. Ablauf (Sequenz)

```mermaid
sequenceDiagram
    participant U as User
    participant C as CLI
    participant R as Kurs-Release
    U->>C: ai-harness-init --lang go --name X
    C->>R: Templates + Skelett holen (gepinnt)
    C->>C: zweiklassig ablegen, Gate-Baseline, stempeln
    C-->>U: Repo bereit (Gate grün)
```
