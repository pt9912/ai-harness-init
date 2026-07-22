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
| `make baseline-verify` | Vendored Baseline unverändert: Integrität **und** Vollständigkeit, netzlos | [`MR-007`](conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) |
| `make docs-check` | Doku-Referenzen grün (links/anchors/ids/codepaths), netzlos (`--network none`) | [`MR-010`](conventions.md#mr-010--d-check-gate-fragment-tool-generiert) |
| `make test` | Command-Guard-Tests (bats) + Go-Unit-Tests (Dockerfile-`test`-Stage) grün | [`ADR-0004`](../docs/plan/adr/0004-durchsetzungs-emission.md), [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make lint` | Go-Lint (golangci-lint, Dockerfile-`lint`-Stage) grün | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make build` | Go-Binary cross-compiliert (Dockerfile-`build`-Stage) | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make shell-lint` | Shell-Hooks/-Helfer lint-clean (shellcheck) | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make ci-lint` | GitHub-Actions-Workflows syntax-clean (actionlint) | [`MR-014`](conventions.md#mr-014--ci-auf-frischem-klon-github-actions) |
| `make gates` | alle aktuell lauffähigen Gates | — |

Der Dogfood-Go-Gate-Stack ist **vollständig**: `make lint` / `make build` / `make test` (Go via Dockerfile-Stages, slice-001a/b) neben `docs-check` / `shell-lint` / `baseline-verify`. **Nicht behauptet**: das Architektur-Gate (a-check, [`LH-FA-07`](../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) — bewusst aufgeschoben, bis hexagonale Schichten existieren; sonst wäre es ein halluziniertes Gate über leerem Prüfbereich ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

**CI** ([`MR-014`](conventions.md#mr-014--ci-auf-frischem-klon-github-actions), slice-027): GitHub Actions fährt `make gates` + `make smoke` + `make mutate` auf **frischem Klon** pro Push/PR — schließt die [`MR-003`](conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Restlücke (der lokale Stop-Hook gibt einen cleanen Tree ohne State frei; „CI ist dort das Netz") und gibt `make mutate` seinen mechanischen Pro-Push-Auslöser. Die **Netz-Sensoren** `regelwerk-check`/`baseline-freshness` laufen **nur nächtlich** — ein Upstream-Ausfall darf keinen Push blockieren. Die CI ruft **ausschließlich `make`-Targets** (keine zweite Gate-Definition). **Was CI nicht prüft:** nichts, was nicht in einem dieser Targets steht — ein grüner CI-Lauf ist keine Aussage über ungetestete Flächen.

**Nicht-Gate-Verify** (verfügbar, **nicht** in `make gates` — wie `regelwerk-check`/`baseline-freshness`): `make smoke` ist der Tier-2-Emit-Smoke (slice-002) — es emittiert die Doc-Gate-Baseline in ein tmp-Repo und lässt das emittierte `docs-check` real laufen (Host-Docker, ggf. Netz-Pull). `make full-smoke` ist der **Voll-E2E-Smoke** (slice-024): Bootstrap in ein tmp-Repo, dann dort der **zusammengeführte** `make gates` ([`MR-010`](conventions.md#mr-010--d-check-gate-fragment-tool-generiert): docs-check + Go-Gates in einem Lauf) — der Happy-Path-Beweis ([`LH-FA-01`](../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)), dass ein frisch gebootstrapptes Repo out-of-the-box grün fährt (die Nutzer-Sicht, die `make smoke` mit seinen getrennten Schritten nicht nimmt). `make mutate` ist der Mutations-Sensor zu [`AGENTS.md`](../AGENTS.md) §3.6 (slice-026): er wendet ein kuratiertes Set von Mutationen an und meldet jeden Wächter, der dabei **grün** bleibt — die Regel ist sonst nur im Feedforward-Quadranten. Beide gehören an DoD-Verify/CI/Wellen-Closure, nicht in den offline-schlanken `make gates`.

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
