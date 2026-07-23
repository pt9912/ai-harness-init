# ai-harness-init

## Was ist ai-harness-init?

Eine CLI, die ein bestehendes Git-Repo mit dem AI-Harness-Kurs-Prozess
bootstrappt: Regelwerk und Templates vom gepinnten Kurs-Stand, die
Doc-Gate-Baseline und ein deterministisch generiertes Sprachskelett mit
verdrahteten Code-Gates. Für Teams, die den Harness nicht von Hand
zusammenkopieren wollen.

## Was kann ich heute tun?

**Nötig:** Docker, git, GNU make — und beim allerersten Lauf einmal Internet (danach arbeitet das
Repo netzunabhängig). Eine Go-Installation ist nicht nötig, alles läuft in Docker. Die ausführliche
Schritt-für-Schritt-Anleitung steht im [Benutzerhandbuch](docs/user/benutzerhandbuch.md).

**Ein Repo aufsetzen** — in ein frisch mit `git init` angelegtes Verzeichnis:

```bash
ai-harness-init --lang go --name "Mein Projekt"
```

Danach läuft dort `make gates` **out-of-the-box grün**: Prozess-Regeln, Vorlagen, Prüfungen und ein
lauffähiges Go-Grundgerüst sind eingerichtet, nichts ist nachzuarbeiten. Ohne `--lang` entsteht ein
rein dokumentgeführtes Repo — die Sprache kommt später per `add-lang` dazu.

**Eine Sprache oder ein Modul nachziehen:**

```bash
ai-harness-init add-lang go apps/api
```

Wiederholbar — mehrere Aufrufe mit verschiedenen Pfaden ergeben ein **Mono-Repo**.

**Denselben Aufruf gefahrlos wiederholen.** Ein zweiter Lauf ist idempotent: das Werkzeug frischt
seine eigenen Dateien auf (repariert Abweichungen, zieht ein neueres Regelwerk nach) und lässt die
selbst gefüllten Dateien — Dokumente, `README.md`, Quellcode — unberührt. Kein `--force`, kein
Abbruch bei vorhandenen Dateien.

**Das Werkzeug bauen.** Fertige Binaries gibt es noch nicht; `ai-harness-init` wird einmalig aus dem
Quellcode gebaut, komplett in Docker:

```bash
make artifact DEST=./bin
```

**Was heute noch fehlt:** vorgefertigte Release-Binaries und weitere Sprachen über `go` hinaus.

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
- **Absicherung + Herkunft:** `make gates` läuft grün und Docker-only; CI fährt ihn pro Push auf einem frischen Klon. Regelwerk und Vorlagen liegen committet vendored unter `.harness/baseline/` (netzunabhängig, reproduzierbar). Der Voll-E2E-Smoke `make full-smoke` bootstrappt real in ein Wegwerf-Repo und lässt dort `make gates` grün laufen.

## Lizenz

[MIT](LICENSE) © 2026 pt9912.
