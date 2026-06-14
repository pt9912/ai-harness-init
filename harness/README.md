# Harness

## Purpose

Einstiegspunkt für Menschen und AI-Agenten. Kein Ersatz für spec/ oder
docs/. Bei Konflikt mit einer kanonischen Quelle gewinnt diese.

Strukturregeln und Adaptionen leben in [`conventions.md`](conventions.md).

## Source precedence

2-Strata-Spec (keine separate Spezifikations-Datei):

| Rang | Datei | Charakter |
|---|---|---|
| 1 | [`spec/lastenheft.md`](../spec/lastenheft.md) | vertraglich abnahmebindend |
| 2 | [`spec/architecture.md`](../spec/architecture.md) | Komponenten/Sequenzen, meilensteinfrei |
| 3 | [`docs/plan/adr/`](../docs/plan/adr/) | Architekturentscheidungen |
| 4 | [`docs/plan/planning/in-progress/roadmap.md`](../docs/plan/planning/in-progress/roadmap.md) | aktuelle Welle |
| 5 | [`README.md`](../README.md) | Projekt-Überblick |
| 6 | [`AGENTS.md`](../AGENTS.md) | Agent-Briefing |
| 7 | diese Datei | Harness-Einstieg |

## Guides (Feedforward)

| Quelle | Inhalt |
|---|---|
| [`spec/lastenheft.md`](../spec/lastenheft.md) | Anforderungen, IDs, Akzeptanzkriterien |
| [`spec/architecture.md`](../spec/architecture.md) | Komponenten, Schichten, Constraints |
| [`docs/plan/adr/`](../docs/plan/adr/) | Architekturentscheidungen |
| [`AGENTS.md`](../AGENTS.md) | Hard Rules, Source Precedence |
| [`conventions.md`](conventions.md) | Strukturregeln, MR-Block, Modus |

## Sensors (Feedback-Gates)

Nur existierende Targets (keine halluzinierten Gates):

| Target | Vertrag | Bindung |
|---|---|---|
| `make docs-check` | Doku-Referenzen grün (links/anchors/ids/codepaths) | — |
| `make test` | Command-Guard-Tests (bash+awk) grün via bats | [`ADR-0004`](../docs/plan/adr/0004-durchsetzungs-emission.md) |
| `make gates` | alle aktuell lauffähigen Gates | — |

**Nicht behauptet** (folgt mit dem Go-Code): `build`/`lint` (Go-Toolchain im gepinnten Image — `go build` / `golangci-lint`); `make test` deckt aktuell die bash+awk-Guard-Suite (bats), die Go-Unit-Tests (`go test`) folgen mit dem Code.

## Traceability

- PRs/Commits nennen mindestens eine `LH-*`- oder `ADR-*`-ID (als Link oder Inline-Code).
- Neue ADRs ergänzen den ADR-Index.

## Minimal agent workflow

1. Diese Datei lesen.
2. Relevante kanonische Quelle lesen (Source Precedence).
3. Betroffene IDs identifizieren.
4. Kleinste sinnvolle Änderung planen.
5. Engsten nützlichen Sensor laufen lassen.
6. Repo-weiten Gate-Lauf vor Handoff (`make gates`).
