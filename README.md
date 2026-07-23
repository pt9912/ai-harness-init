# ai-harness-init

## Was ist ai-harness-init?

`ai-harness-init` ist ein Kommandozeilen-Werkzeug, das ein bestehendes Git-Repo mit dem
**AI-Harness-Prozess** aufsetzt — ein festes Set aus Prozess-Regeln, Dokument-Vorlagen und
automatischen Prüfungen (**Gates**), das die Zusammenarbeit von Mensch und KI-Agenten in einem
Projekt geordnet hält. Nach einem Aufruf laufen die Prüfungen im Repo sofort grün, ohne
Nacharbeit. Für Teams, die den Prozess nicht von Hand zusammenkopieren wollen.

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

Den Harness von Hand aufzusetzen ist mechanisch und fehleranfällig — vor allem bei den
automatischen Prüfungen (den **Gates**). Schnell baut man versehentlich eine Prüfung ein, die
zwar dasteht, aber nichts wirklich prüft: eine trügerische Sicherheit. `ai-harness-init` richtet
stattdessen nur Prüfungen ein, die im fertigen Repo **wirklich laufen** — und legt lieber gar
nichts an als etwas, das es nicht belegen kann.

## Kerngedanke

**Nichts entsteht aus dem Nichts.** Den *Inhalt* — Prozess-Regeln, Dokument-Vorlagen, die
Durchsetzungs-Skripte — holt das Werkzeug aus einer festgelegten, geprüften Quelle (dem Kurs-Stand)
und denkt ihn sich nicht aus. Nur das rein *Mechanische* — Verzeichnis-Struktur, Sprach-Grundgerüst,
die Prüf-Bausteine — erzeugt es selbst, und zwar reproduzierbar: gleiche Eingabe, gleiches Ergebnis.
Und es richtet nur ein, was auch **wirklich läuft** — lieber gar keine Prüfung als eine, die bloß
dasteht.

## Was macht es vertrauenswürdig?

- **Prozess:** [`AGENTS.md`](AGENTS.md) (Hard Rules), [`harness/README.md`](harness/README.md) (Source Precedence, Sensors).
- **Verträge:** [`spec/lastenheft.md`](spec/lastenheft.md) (`LH-*`-IDs mit Akzeptanzkriterien).
- **Entscheidungen:** [`docs/plan/adr/`](docs/plan/adr/) — z. B. [`ADR-0005`](docs/plan/adr/0005-ziel-repo-distribution.md) (Ziel-Repo-Distributionsmodell).
- **Gates:** `make docs-check` (links/anchors/ids/codepaths), `make test` (Command-Guard bats + Go-Unit-Tests), `make lint`/`make build` (Go via Dockerfile-Stages), `make shell-lint` (shellcheck) — grün; `make gates` bündelt sie. (Das arch-Gate a-check folgt mit dem Go-Code.)
- **Absicherung + Herkunft:** `make gates` läuft grün und Docker-only; CI fährt ihn pro Push auf einem frischen Klon. Regelwerk und Vorlagen liegen committet vendored unter `.harness/baseline/` (netzunabhängig, reproduzierbar). Der Voll-E2E-Smoke `make full-smoke` bootstrappt real in ein Wegwerf-Repo und lässt dort `make gates` grün laufen.

## Lizenz

[MIT](LICENSE) © 2026 pt9912.
