# ai-harness-init

## Was ist ai-harness-init?

Eine CLI, die ein bestehendes Git-Repo mit dem AI-Harness-Kurs-Prozess
bootstrappt: Regelwerk und Templates vom gepinnten Kurs-Stand, die
Doc-Gate-Baseline und ein deterministisch generiertes Sprachskelett mit
verdrahteten Code-Gates. Für Teams, die den Harness nicht von Hand
zusammenkopieren wollen.

## Was kann ich heute tun?

Ein Verzeichnis **vollständig bootstrappen** (`--lang go`): Nach dem Lauf fährt das
Zielrepo sein eigenes `make gates` **out-of-the-box grün** — der Happy-Path aus
[`LH-FA-01`](spec/lastenheft.md#lh-fa-01--repo-bootstrappen), Meilenstein **M2** erreicht. Der Voll-E2E-Smoke
`make full-smoke` belegt es real: Bootstrap in ein Wegwerf-Repo → dort `make gates`
Exit 0 (docs-check 0 Befunde, Go-Gates grün).

Der Lauf schreibt ins Zielrepo: Regelwerk + Templates (prüfsummen-verifiziert,
[`LH-FA-09`](spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)), die Doc-Gate-Baseline, die Template-Ablage,
ein deterministisch generiertes Sprachskelett mit **verdrahteten** Code-Gates (der
Generator löst den Fetch ab, [`ADR-0005`](docs/plan/adr/0005-ziel-repo-distribution.md)) und die
Root-README. Eine unbekannte Sprache bricht sauber ab (Exit 2 + Liste).

**Ein Sprachmodul nachziehen** (`ai-harness-init add-lang <sprache> <pfad>`): ein
**wiederholbarer** Schritt, der einem bereits gebootstrappten Repo ein Skelett unter
`<pfad>` + sein Code-Gate-Fragment (`harness/mk/<modul>.mk`, Build-Kontext `<pfad>`) +
das `blocked/<sprache>`-Guard-Fragment hinzufügt — mehrere Aufrufe ergeben ein
**Mono-Repo** ([`LH-FA-04`](spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
[`ADR-0007`](docs/plan/adr/0007-bootstrap-phasen.md)). `--lang <X>` beim Init ist die
One-Shot-Kurzform (Init + ein `add-lang(<X>, .)`).

Das Binary entsteht Docker-only ([`ADR-0003`](docs/plan/adr/0003-go-native-binaries.md), `build`-Stage) —
kein eingechecktes Executable (`cmd/ai-harness-init` ist Go-Quellcode): `make artifact
DEST=<dir>` zieht es auf den Host. Die Schritt-für-Schritt-Anleitung (bauen, aufrufen,
prüfen) steht im [Benutzerhandbuch](docs/user/benutzerhandbuch.md).

**Was noch fehlt:** vorgefertigte Release-Binaries (heute baut man aus dem
Quellcode) und weitere Sprach-Profile über `go` hinaus
([`LH-FA-04`](spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)).

Der Harness selbst — dieses Repo — ist voll abgesichert: der Gate-Stack läuft grün
und Docker-only (`make gates` bündelt `baseline-verify` · `docs-check` mit d-check
v0.51.1 · `lint` · `build` · `test` · `shell-lint` · `ci-lint`), und CI fährt ihn pro
Push auf frischem Klon. Regelwerk + Templates liegen committet vendored unter
`.harness/baseline/v3.5.0/` (netzlos, [`MR-007`](harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).

Welche Wellen als Nächstes kommen, sagt die
[roadmap](docs/plan/planning/in-progress/roadmap.md) — sie ist die Sequenzierungs-Autorität, dieses
README wiederholt sie bewusst nicht. Keine Erfolgsmeldung ohne lauffähigen Beleg.

## Warum ai-harness-init?

Der Hand-Bootstrap ist mechanisch, aber fehleranfällig — besonders die
Code-Gates: ein fehlender oder falsch verdrahteter Gate ist ein
halluzinierter Gate (Modul 13). ai-harness-init verdrahtet stattdessen
Gates, die im emittierten Repo real laufen — und emittiert lieber nichts
als etwas Unbelegtes.

## Kerngedanke

**Hole die Kurs-Quelle, generiere das Mechanische.** Nichts entsteht
aus dem Nichts. Der gepinnte Kurs-Stand ist die **Single Source of Truth (SSoT)** —
die eine, verbindliche Quelle der Wahrheit für Prozess und Vorlagen. Regelwerk,
Doc-Templates, Durchsetzungsschicht und Workflow-Commands kommen **gefetcht** von
dort; die SSoT bleibt der Kurs. Verzeichnis-Gerüst, Sprachskelett und die Gate-Fragmente
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
