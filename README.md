# ai-harness-init

## Was ist ai-harness-init?

Eine CLI, die ein bestehendes Git-Repo mit dem AI-Harness-Kurs-Prozess
bootstrappt: Regelwerk und Templates vom gepinnten Kurs-Stand, die
Doc-Gate-Baseline und ein deterministisch generiertes Sprachskelett mit
verdrahteten Code-Gates. Für Teams, die den Harness nicht von Hand
zusammenkopieren wollen.

## Was kann ich heute tun?

Den Bootstrap **fahren, aber nur als Teil-Ergebnis** — und noch nicht mit einem
fertigen Befehl. Es gibt kein `run`-Target und kein eingechecktes Binary
(`cmd/ai-harness-init` ist Go-Quellcode, kein Executable); das Binary entsteht
Docker-only ([`ADR-0003`](docs/plan/adr/0003-go-native-binaries.md), `artifact`-Stage) und läuft heute
end-to-end nur über `make smoke` — gegen ein Wegwerf-Repo, `--lang go`.

Dieser Lauf schreibt ins Zielrepo: Regelwerk + Templates (prüfsummen-verifiziert,
[`LH-FA-09`](spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)), die Doc-Gate-Baseline, die Template-Ablage und ein
transitorisch gestagtes Sprachskelett (der deterministische Generator löst den
Fetch ab, [`ADR-0005`](docs/plan/adr/0005-ziel-repo-distribution.md)). Eine unbekannte Sprache bricht sauber
ab (Exit 2 + Liste).

**Was noch fehlt — der eigentliche Zweck:** ein Repo, in dem `make gates`
out-of-the-box grün läuft ([`LH-FA-01`](spec/lastenheft.md#lh-fa-01--repo-bootstrappen) Happy-Path). Dazu fehlen der
Sprachskelett-Generator, die Verdrahtung der Code-Gates und die Root-README.
Bis dahin ist der Emit ein Teil-Bootstrap, kein fertiges Repo.

Der Harness selbst — dieses Repo — ist dagegen voll abgesichert: der Gate-Stack
läuft grün und Docker-only (`make gates` bündelt `baseline-verify` · `docs-check`
mit d-check v0.51.1 · `lint` · `build` · `test` · `shell-lint` · `ci-lint`), und CI
fährt ihn pro Push auf frischem Klon. Regelwerk + Templates liegen committet
vendored unter `.harness/baseline/v3.5.0/` (netzlos, [`MR-007`](harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).

Welche Slices den fehlenden Rest in welcher Reihenfolge liefern, sagt die
[roadmap](docs/plan/planning/in-progress/roadmap.md) — sie ist die Sequenzierungs-Autorität, dieses README
wiederholt sie bewusst nicht. Keine Erfolgsmeldung ohne lauffähigen Beleg.

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

Welche Klasse woher kommt, entscheidet [`ADR-0005`](docs/plan/adr/0005-ziel-repo-distribution.md); dort steht auch, warum.

## Was macht es vertrauenswürdig?

- **Prozess:** [`AGENTS.md`](AGENTS.md) (Hard Rules), [`harness/README.md`](harness/README.md) (Source Precedence, Sensors).
- **Verträge:** [`spec/lastenheft.md`](spec/lastenheft.md) (`LH-*`-IDs mit Akzeptanzkriterien).
- **Entscheidungen:** [`docs/plan/adr/`](docs/plan/adr/) — z. B. [`ADR-0005`](docs/plan/adr/0005-ziel-repo-distribution.md) (Ziel-Repo-Distributionsmodell).
- **Gates:** `make docs-check` (links/anchors/ids/codepaths), `make test` (Command-Guard bats + Go-Unit-Tests), `make lint`/`make build` (Go via Dockerfile-Stages), `make shell-lint` (shellcheck) — grün; `make gates` bündelt sie. (Das arch-Gate a-check folgt mit dem Go-Code.)

## Lizenz

[MIT](LICENSE) © 2026 pt9912.
