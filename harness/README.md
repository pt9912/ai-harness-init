# Harness

## Purpose

Einstiegspunkt für Menschen und AI-Agenten. Kein Ersatz für spec/ oder
docs/. Bei Konflikt mit einer kanonischen Quelle gewinnt diese.

Strukturregeln leben in [`conventions.md`](conventions.md); die Adaptionen selbst liegen als je
eine Datei unter [`conventions/`](conventions/), und `conventions.md` ist ihr Index.

## Source precedence

3-Strata-Spec (Vertrag › Technik › Sicht, [`MR-019`](conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)):

| Rang | Datei | Charakter |
|---|---|---|
| 1 | [`spec/lastenheft.md`](../spec/lastenheft.md) | vertraglich abnahmebindend |
| 2 | [`spec/spezifikation.md`](../spec/spezifikation.md) | technisch verbindlich, ohne Vertragsänderung fortschreibbar |
| 3 | [`spec/architecture.md`](../spec/architecture.md) | Komponenten/Sequenzen, meilensteinfrei |
| 4 | [`docs/plan/adr/`](../docs/plan/adr/) | Architekturentscheidungen |
| 5 | [`docs/plan/planning/in-progress/roadmap.md`](../docs/plan/planning/in-progress/roadmap.md) | aktuelle Welle |
| 6 | [`docs/user/`](../docs/user/) *(falls vorhanden)* | Operations, Quality, Releasing |
| 7 | [`README.md`](../README.md) | Projekt-Überblick |
| 8 | [`AGENTS.md`](../AGENTS.md) | Agent-Briefing |
| 9 | diese Datei | Harness-Einstieg |

## Guides (Feedforward)

| Quelle | Inhalt |
|---|---|
| [`spec/lastenheft.md`](../spec/lastenheft.md) | Anforderungen, IDs, Akzeptanzkriterien |
| [`spec/spezifikation.md`](../spec/spezifikation.md) | technische Festlegungen: Defaults, Tracing-Felder, externe Fassungen |
| [`spec/architecture.md`](../spec/architecture.md) | Komponenten, Schichten, Constraints |
| [`docs/plan/adr/`](../docs/plan/adr/) | Architekturentscheidungen |
| [`AGENTS.md`](../AGENTS.md) | Hard Rules, Source Precedence |
| [`conventions.md`](conventions.md) | Strukturregeln, Index des MR-Blocks, Modus |
| [`conventions/`](conventions/) | die MR-Einträge selbst, eine Datei je Eintrag |

## Sensors (Feedback-Gates)

Nur existierende Targets (keine halluzinierten Gates). Ein Gate, dessen Vertrag mehr als
einen Satz braucht, trägt seine Prosa unter `harness/sensors/<target>.md`; die Target-Zelle
wird dann zum Link auf die Datei.

| Target | Vertrag | Bindung |
|---|---|---|
| `make baseline-verify` | Vendored Baseline unverändert: Integrität **und** Vollständigkeit, netzlos | [`MR-007`](conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) |
| [`make docs-check`](sensors/doc-check.md) | Doku-Referenzen grün (links/anchors/ids/matrix/codepaths/spans/planning/targets), netzlos (`--network none`) — im Prüfbereich seiner Module | [`MR-010`](conventions.md#mr-010--d-check-gate-fragment-tool-generiert) |
| `make test` | Command-Guard-Tests (bats) + Go-Unit-Tests (Dockerfile-`test`-Stage) grün | [`ADR-0004`](../docs/plan/adr/0004-durchsetzungs-emission.md), [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make lint` | Go-Lint (golangci-lint, Dockerfile-`lint`-Stage) grün | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make build` | Go-Binary cross-compiliert (Dockerfile-`build`-Stage) | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make shell-lint` | Shell-Hooks/-Helfer lint-clean (shellcheck) | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make ci-lint` | GitHub-Actions-Workflows syntax-clean (actionlint) | [`MR-014`](conventions.md#mr-014--ci-auf-frischem-klon-github-actions) |
| [`make comment-claims`](sensors/comment-claims.md) | Kommentar-Behauptungen nennen ihren Sensor; genannte Tests existieren — im Prüfbereich, enger als der Gate-Stempel | [`AGENTS.md`](../AGENTS.md) §3.6 |
| `make host-bin` | Träger (Produkt-Binär) für die **Host**-Plattform gebaut und im gitignorierten Zustands-Bereich abgelegt (Docker-only, GOOS/GOARCH aus `uname`) | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make span-check` | Träger vorhanden **und** sein Unterkommando `span-emit` funktionsfähig; Ablageort real `git check-ignore`-geprüft | [`spec/spezifikation.md`](../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 |
| `make gates` | alle aktuell lauffähigen Gates | — |

### Werkzeuge (kein Gate)

Genannt, weil ein Lauf sie braucht — kein Gate-Versprechen, darum keine `make X`-Zeile in
[`AGENTS.md`](../AGENTS.md) §4 nötig (kuratiert in `targets.exempt-targets`,
[`.d-check.yml`](../.d-check.yml)). Die übrigen `exempt-targets` sind reine Utility-/
Advisory-Ziele ohne Prosa-Erwähnung, deren einzige Dokumentation ihr eigener `## `-Hilfetext
ist (`make help` listet sie).

| Target | Tut was | Bindung |
|---|---|---|
| [`make smoke`](sensors/smoke.md) | Tier-2-Emit-Smoke: emittiertes `docs-check` real gegen ein tmp-Repo | kein Gate · slice-002 |
| [`make full-smoke`](sensors/full-smoke.md) | Voll-E2E: Bootstrap in tmp-Repo → dort `make gates` out-of-the-box grün | kein Gate · [`LH-FA-01`](../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) |
| [`make mutate`](sensors/mutate.md) | Mutations-Sensor: färbt jede kuratierte Mutation ihren Wächter rot? | kein Gate · [`AGENTS.md`](../AGENTS.md) §3.6 |
| `make span-report` | Token-Bilanz je Rolle aus dem Span-Bestand, read-only und netzlos | kein Gate — Bericht |
| `make span-clean` | räumt den lokalen Span-Bestand weg (ausdrücklich, kein Automatismus) | kein Gate |
| [`make hook-overhead`](sensors/hook-overhead.md) | misst den Aufschlag je Tool-Call (Median) | kein Gate · [`ADR-0011`](../docs/plan/adr/0011-telemetrie-erfassung-policy.md) |
| [`make slice-mv`](sensors/slice-mv.md) | Lifecycle-Wechsel eines Slice inklusive seiner Verweise | kein Gate · [`AGENTS.md`](../AGENTS.md) §3.3 |
| [`make archive-welle`](sensors/archive-welle.md) | archiviert die Zeitdokumente einer geschlossenen Welle | kein Gate · [`ADR-0033`](../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) |
| [`make vendor-baseline`](sensors/vendor-baseline.md) | legt den eigenen vendored Baum aus dem Release-Asset an | kein Gate · [`MR-007`](conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) |
| [`make commit-msg-check`](sensors/commit-msg-check.md) | prüft eine Commit-Message-Datei gegen Traceability-Kennung | kein Gate — Träger ist der PreToolUse-Hook |
| [`make history-range-guard`](sensors/history-range-guard.md) | Vorlauf-Wächter: angeforderte Range auflösbar **und** nicht leer | kein Gate |
| [`make adr-immutable`](sensors/adr-immutable.md) | hält den Kern einer `Accepted`-ADR über einer Range unverändert | kein Gate · [`AGENTS.md`](../AGENTS.md) §3.4 |
| [`make doc-tracked`](sensors/doc-tracked.md) | sagt, ob ein verlinktes Ziel im git-Index steht | kein Gate |
| [`make doc-structure`](sensors/doc-structure.md) | sagt, ob eine erwartete Section-Überschrift fehlt (inert ohne `structure:`-Block) | kein Gate |
| `make regelwerk-check` | Upstream-Content-Drift des Baseline-ZIP auditieren (Netz) | kein Gate — nur nächtlich |
| `make baseline-freshness` | neueren Upstream-Tag als `BASELINE_TAG` melden (Netz, read-only) | kein Gate — nur nächtlich |
| `make record-gates` | Working-Tree-Hash-Nachweis für den Stop-Hook | kein Gate |

## Traceability

- PRs/Commits nennen mindestens eine `LH-*`- oder `ADR-*`-ID (als Link oder Inline-Code).
- Neue ADRs ergänzen den ADR-Index.

## Safety and scope boundaries

**Der Dogfood-Go-Gate-Stack ist vollständig**: `make lint` / `make build` / `make test` (Go
via Dockerfile-Stages) neben `docs-check` / `shell-lint` / `baseline-verify`. **Nicht
behauptet:** das Architektur-Gate (a-check,
[`LH-FA-07`](../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) — der Dogfood ist
**flach**, hier hätte a-check einen leeren Prüfbereich
([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
**Emittiert wird es trotzdem** (emitted-only): ein Zielrepo mit einem schichten-tragenden
Layout — `--arch hexslice` (go, cpp) oder `--arch hexagonal` (go) — bekommt `.a-check.yml` +
`a-check.mk` und fährt a-check in seinem `make gates` mit; ein flaches Ziel bekommt keines.
Welche Layouts das sind, entscheidet keine Namensliste, sondern die strukturelle Frage, ob
das Layout eine geprüfte Schicht trägt. Belegt in [`make full-smoke`](sensors/full-smoke.md)
(beide Richtungen + ein verbotener Import, der das emittierte Gate rot färbt), nicht hier.

**CI** ([`MR-014`](conventions.md#mr-014--ci-auf-frischem-klon-github-actions)): GitHub
Actions fährt `make gates` + [`make smoke`](sensors/smoke.md) + [`make mutate`](sensors/mutate.md)
auf **frischem Klon** pro Push/PR — schließt die
[`MR-003`](conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Restlücke
(der lokale Stop-Hook gibt einen cleanen Tree ohne State frei; „CI ist dort das Netz") und
gibt `make mutate` seinen mechanischen Pro-Push-Auslöser. Die Netz-Sensoren
`regelwerk-check`/`baseline-freshness` laufen **nur nächtlich** — ein Upstream-Ausfall darf
keinen Push blockieren. Die CI ruft **ausschließlich `make`-Targets** (keine zweite
Gate-Definition). **Was CI nicht prüft:** nichts, was nicht in einem dieser Targets steht —
ein grüner CI-Lauf ist keine Aussage über ungetestete Flächen.

## Minimal agent workflow

1. Diese Datei lesen.
2. Relevante kanonische Quelle lesen (Source Precedence).
3. Betroffene IDs identifizieren.
4. Kleinste sinnvolle Änderung planen.
5. Engsten nützlichen Sensor laufen lassen.
6. Repo-weiten Gate-Lauf vor Handoff (`make gates`).

## Leseordnung

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-harness-dateien.md`
§harness/README.md als Einstiegspunkt — die Menschen-Hälfte des Einstiegs:
drei bis fünf **geordnete** Zeiger, was ein neuer Mensch zuerst liest und was
bei Bedarf; eine Leseordnung, die alles nennt, ist keine.

1. [`AGENTS.md`](../AGENTS.md) §3 — die Hard Rules, vor jedem Lauf.
2. [`spec/lastenheft.md`](../spec/lastenheft.md) — was dieses Repo vertraglich
   liefert.
3. [`docs/plan/planning/in-progress/roadmap.md`](../docs/plan/planning/in-progress/roadmap.md)
   — woran gerade gearbeitet wird.
4. [`conventions.md`](conventions.md) — bei Bedarf: der Index der Adaptionen von der
   Baseline (der Eintrag selbst liegt unter [`conventions/`](conventions/)), Modus-Deklaration.
