# ai-harness-init

## Was ist ai-harness-init?

Eine CLI, die ein bestehendes Git-Repo mit dem AI-Harness-Kurs-Prozess
bootstrappt: Regelwerk und Templates vom gepinnten Kurs-Stand, die
Doc-Gate-Baseline und ein deterministisch generiertes Sprachskelett mit
verdrahteten Code-Gates. Für Teams, die den Harness nicht von Hand
zusammenkopieren wollen.

## Was kann ich heute tun?

**Ehrlicher Stand (2026-07-18):** Der **Offline-Kern ist gebaut** — Meilenstein M1
erreicht, welle-01 geschlossen ([welle-01-results](docs/plan/planning/done/welle-01-results.md)).
Das Go-Binary `cmd/ai-harness-init --lang <X> --name <Y>` leistet heute:

- **Doc-Gate-Baseline emittieren** — `.d-check.yml` + `d-check.mk` (Runtime-Codegen aus
  `d-check --print-mk`; slice-002);
- **Template-Baseline zweiklassig ablegen** — Singletons → gestempelte `.md`,
  Wiederkehrende → co-located `.template.md` (slice-003);
- **Sprachskelett vom gepinnten Kurs-Tag fetchen** in einen Staging-Bereich (slice-004a);
  unbekannte Sprache → Exit 2 + Liste.

Der Gate-Stack läuft grün, Docker-only: `make baseline-verify` · `docs-check` (d-check
v0.51.1) · `lint` · `build` · `test` (bats + Go-Unit) · `shell-lint`; `make gates` bündelt
sie. `make smoke` (Nicht-Gate) fährt den echten Bootstrap host-orchestriert. Betriebsregelwerk
+ Templates liegen committet vendored unter `.harness/baseline/v3.5.0/` (netzlos, [`MR-007`](harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache));
Durchsetzungsschicht (Command-Guard bash+awk, Gate-Nachweis, Regelwerk-Injektion) adoptiert.

**In Arbeit, noch nicht behauptet:** der **Baseline-Emit** ins Zielrepo (Regelwerk +
Templates + Prüfsummen-Verifier, [`LH-FA-09`](spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)) ist implementiert, aber der
unabhängige Review hat ein **merge-blockierendes HIGH** gefunden — deshalb steht die
Fähigkeit oben bewusst **nicht** in der Liste. Sie wird hier erst genannt, wenn sie
belegt trägt.

**Noch offen (welle-02 → M2 in welle-03):** Distributions-Umbau abschließen (Embed
entfernen, Skelett-**Generator**, Verdrahtung), dann **Root-README** emittieren (slice-005)
und der **Voll-E2E-Smoke** (slice-024). Erst dann läuft `make gates` im *emittierten* Repo
out-of-the-box grün ([`LH-FA-01`](spec/lastenheft.md#lh-fa-01--repo-bootstrappen) Happy-Path).

**Nächster Schritt:** die Review-Findings zu slice-022a auflösen. Siehe
[roadmap](docs/plan/planning/in-progress/roadmap.md) (Aktuelle Welle) und
[welle-02](docs/plan/planning/welle-02-fetch-und-readme.md) (§4 Slices).

Keine Erfolgsmeldung ohne lauffähigen Beleg.

## Warum ai-harness-init?

Der Hand-Bootstrap ist mechanisch, aber fehleranfällig — besonders die
Code-Gates: ein fehlender oder falsch verdrahteter Gate ist ein
halluzinierter Gate (Modul 13). ai-harness-init verdrahtet stattdessen
Gates, die im emittierten Repo real laufen — und emittiert lieber nichts
als etwas Unbelegtes.

## Kerngedanke

**Hole, was Kurs-SSoT ist — generiere, was mechanisch ist.** Nichts entsteht
aus dem Nichts. Regelwerk, Doc-Templates, Durchsetzungsschicht und
Workflow-Commands kommen **gefetcht** vom gepinnten Kurs-Stand; dort bleibt die
Single Source of Truth. Verzeichnis-Gerüst, Sprachskelett und die Gate-Fragmente
erzeugt das Tool **deterministisch aus eigenem Wissen** — nachvollziehbar wie
`d-check --print-mk`. Der `AGENTS.md`-Inhalt bleibt tool-fremd: den autort ein
Mensch oder Agent aus der gefetchten Vorlage. Emittiert wird nur, was wirklich
läuft ([`LH-QA-01`](spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

> Bis 2026-07-19 stand hier *„Picker, kein Generator"*. [`ADR-0005`](docs/plan/adr/0005-ziel-repo-distribution.md) hat **nur die
> Skelett-Klasse** auf einen deterministischen Generator umgestellt (das
> `//go:embed`-Duplikat des Kurs-Template-Satzes fiel damit weg); Durchsetzung
> und Workflow-Commands bleiben ausdrücklich Picker.

## Was macht es vertrauenswürdig?

- **Prozess:** [`AGENTS.md`](AGENTS.md) (Hard Rules), [`harness/README.md`](harness/README.md) (Source Precedence, Sensors).
- **Verträge:** [`spec/lastenheft.md`](spec/lastenheft.md) (`LH-*`-IDs mit Akzeptanzkriterien).
- **Entscheidungen:** [`docs/plan/adr/`](docs/plan/adr/) — z. B. [`ADR-0005`](docs/plan/adr/0005-ziel-repo-distribution.md) (Ziel-Repo-Distributionsmodell).
- **Gates:** `make docs-check` (links/anchors/ids/codepaths), `make test` (Command-Guard bats + Go-Unit-Tests), `make lint`/`make build` (Go via Dockerfile-Stages), `make shell-lint` (shellcheck) — grün; `make gates` bündelt sie. (Das arch-Gate a-check folgt mit dem Go-Code.)

## Lizenz

[MIT](LICENSE) © 2026 pt9912.
