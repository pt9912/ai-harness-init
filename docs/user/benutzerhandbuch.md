# Benutzerhandbuch: ai-harness-init

**Handbuch-Version:** 1.6
**Software-Stand:** `v0.1.0` — erstes Release mit **vorgefertigten Programmen für sechs Plattformen** (linux · macos · windows × amd64 · arm64). Inhaltlich: **phasierter** Bootstrap (Init sprach-agnostisch, `--lang` optional; Sprachmodule per `add-lang`, wiederholbar/Mono-Repo; **idempotenter** Re-Lauf) und **Bauform-Achse** `--arch` (`flat` oder `hexslice`; bei `hexslice` kommt das Architektur-Gate mit). Zielsprachen `go` und `cpp` (C++; weitere folgen); `hexslice` liefert derzeit nur der Go-Renderer.
**Stand:** 2026-07-26
**Verantwortlich:** ai-harness-init-Team (pt9912)

---

`ai-harness-init` ist ein Kommandozeilen-Werkzeug. Dieses Handbuch beschreibt, **wie Sie damit ein Projekt-Repository aufsetzen** — nicht, wie das Werkzeug intern funktioniert. Sie kommen ans Ziel, ohne den Quellcode zu verstehen.

## Inhalt

1. [Einleitung](#1-einleitung)
2. [Installation und Zugriff](#2-installation-und-zugriff)
3. [Erste Schritte](#3-erste-schritte)
4. [Aufgaben](#4-aufgaben)
5. [Konfiguration](#5-konfiguration)
6. [Was wird angelegt](#6-was-wird-angelegt)
7. [Fehlerbehebung](#7-fehlerbehebung)
8. [Häufige Fragen (FAQ)](#8-häufige-fragen-faq)
9. [Glossar](#9-glossar)
10. [Anhang](#10-anhang)
11. [Änderungshistorie](#11-änderungshistorie)

---

## 1. Einleitung

### Zweck der Software

`ai-harness-init` richtet ein bestehendes Verzeichnis (typischerweise ein frisch angelegtes Git-Repository) so ein, dass es dem **AI-Harness-Prozess** folgt: ein festes Set aus Prozess-Regeln, Vorlagen und automatischen Prüfungen (**Gates**), das die Zusammenarbeit von Mensch und KI-Agenten in einem Software-Projekt geordnet hält.

Von Hand ist dieses Aufsetzen mechanisch, aber fehleranfällig. `ai-harness-init` nimmt Ihnen das ab: Nach einem Aufruf haben Sie ein Repository, in dem die Qualitäts-Prüfungen **sofort grün laufen** (`make gates`), ohne dass Sie etwas nacharbeiten müssen.

### Zielgruppe dieses Handbuchs

Entwicklerinnen, Entwickler und Teams, die ein neues Projekt mit dem AI-Harness-Prozess starten wollen. Sie sollten mit der Kommandozeile und mit `git` umgehen können. **Kein** Vorwissen über den internen Aufbau des Werkzeugs ist nötig.

### Voraussetzungen

Auf dem Rechner, der `ai-harness-init` ausführt, brauchen Sie:

* **Docker** — läuft und ist bedienbar (das Werkzeug ruft während des Aufsetzens Docker auf).
* **git** — für das Projekt-Repository.
* **Netzwerk-Zugang** — **einmalig** beim ersten Aufruf. `ai-harness-init` lädt das Regelwerk vom festgelegten Kurs-Stand. Danach ist Ihr Repository netzunabhängig.
* **GNU `make`** — um das aufgesetzte Repository anschließend zu prüfen.

Eine lokale Go-Installation ist **nicht** nötig — alles läuft über Docker.

---

## 2. Installation und Zugriff

### Systemanforderungen

* Ein Betriebssystem mit Docker — Linux, macOS oder Windows (für alle drei gibt es fertige Programme; was auf welcher Plattform geprüft wird, steht im Kasten unten).
* `git` und GNU `make` auf dem Pfad.
* Beim ersten Aufruf: Internet-Zugang.

> **Was wo geprüft wird — damit Sie wissen, worauf Sie sich stützen.** Zwei verschiedene Prüfungen,
> und sie decken nicht dasselbe:
>
> * **Bei jeder Änderung am Quellcode** läuft der **vollständige Durchlauf** (Repo aufsetzen,
>   Prüfungen grün) — auf **Linux/Intel-AMD**, auf einer Maschine.
> * **Beim Erstellen eines Release** wird auf **allen sechs** ausgelieferten Dateien geprüft, dass
>   das Programm auf seiner Plattform **startet**. Mehr nicht.
>
> Für **macOS**, **Windows** und **Linux/ARM** ist damit belegt, dass das Programm dort **läuft** —
> **nicht**, dass ein kompletter Durchlauf dort durchläuft. Grund für macOS und Windows: die
> gehosteten Prüf-Maschinen können die benötigten Linux-Container nicht fahren.

### Das Werkzeug bereitstellen

Es gibt **zwei Wege**. Empfohlen ist der **Download** — ab `v0.1.0` liegen fertige Programme für sechs Plattformen bereit. Den Bau aus dem Quellcode brauchen Sie nur, wenn Sie einen Stand **ohne** Versions-Kennzeichnung verwenden wollen.

#### Weg A — fertiges Programm herunterladen (empfohlen)

**Vorgehen**

1. Öffnen Sie die [Release-Seite](https://github.com/pt9912/ai-harness-init/releases/latest) und laden Sie die Datei für Ihr System herunter:

   | System | Datei |
   |---|---|
   | Linux, Intel/AMD | `ai-harness-init-linux-amd64` |
   | Linux, ARM | `ai-harness-init-linux-arm64` |
   | macOS, Intel | `ai-harness-init-darwin-amd64` |
   | macOS, Apple Silicon | `ai-harness-init-darwin-arm64` |
   | Windows, Intel/AMD | `ai-harness-init-windows-amd64.exe` |
   | Windows, ARM | `ai-harness-init-windows-arm64.exe` |

2. Machen Sie die Datei ausführbar und legen Sie sie unter dem kurzen Namen in einen Ordner Ihres Suchpfads (Linux/macOS; das Beispiel nimmt Linux/Intel und den Ordner `~/.local/bin`):

   ```bash
   chmod +x ai-harness-init-linux-amd64
   mkdir -p ~/.local/bin
   mv ai-harness-init-linux-amd64 ~/.local/bin/ai-harness-init
   ```

   **Prüfen Sie, ob dieser Ordner in Ihrem Suchpfad liegt** (`echo $PATH`) — auf macOS ist `~/.local/bin` standardmäßig **nicht** enthalten. Falls nicht, nehmen Sie einen Ordner, der drin ist, oder ergänzen Sie den Pfad in Ihrer Shell-Konfiguration.

   Unter Windows genügt es, die `.exe`-Datei in einen Ordner Ihres Suchpfads zu legen.

3. Prüfen Sie, dass es läuft:

   ```bash
   ai-harness-init --help
   ```

> **Hinweis für macOS:** Lädt ein Browser die Datei herunter, versieht macOS sie mit einem Quarantäne-Vermerk und verweigert den Start. `xattr -d com.apple.quarantine <datei>` entfernt ihn.

**Ergebnis**

Liegt der Ordner in Ihrem Suchpfad, ist das Programm unter dem kurzen Namen `ai-harness-init` aufrufbar. **Das Handbuch verwendet ab hier diesen kurzen Aufruf** — das gilt für beide Wege.

#### Weg B — aus dem Quellcode bauen

Sie bauen das Programm einmalig selbst — das geschieht komplett in Docker, Sie brauchen dafür keine Go-Installation.

**Vorgehen**

1. Holen Sie den Quellcode:

   ```bash
   git clone https://github.com/pt9912/ai-harness-init.git
   cd ai-harness-init
   ```

2. Bauen Sie das Programm und legen Sie es in einen Ordner Ihrer Wahl (im Beispiel den Ordner **bin**):

   ```bash
   make artifact DEST=./bin
   ```

3. Prüfen Sie, dass es läuft:

   ```bash
   ./bin/ai-harness-init --help
   ```

**Ergebnis**

Im Ordner **bin** liegt das ausführbare Programm `ai-harness-init`. Kopieren Sie es bei Bedarf an eine Stelle auf Ihrem Pfad (zum Beispiel nach `~/.local/bin`), damit Sie es überall unter dem kurzen Namen aufrufen können.

> **Hinweis:** `make artifact DEST=./bin` verlangt die Angabe `DEST`. Ohne sie bricht der Befehl mit einer klaren Meldung ab. Den Zielordner müssen Sie **nicht** vorher anlegen — er wird erstellt, falls er fehlt.

---

## 3. Erste Schritte

### Schnelleinstieg

So setzen Sie ein neues Projekt in unter einer Minute auf:

```bash
mkdir mein-projekt && cd mein-projekt
git init
ai-harness-init --lang go --name "Mein Projekt"
```

Anschließend prüfen Sie, dass alles grün ist:

```bash
make gates
```

### Beispielablauf

Während des Aufsetzens sehen Sie eine Abschluss-Zeile wie:

```text
ai-harness-init: Bootstrap (Baseline v3.5.2 vendored + Doc-Gate + Aggregator + Durchsetzung + Template-Baseline) — --lang=go (Skelett verdrahtet).
```

Das bedeutet: Regelwerk und Vorlagen liegen im Repository, die Prüfungen sind verdrahtet, und ein lauffähiges Go-Grundgerüst ist eingebaut. `make gates` läuft danach ohne Fehler durch. (Ohne `--lang` steht statt „Skelett verdrahtet“ die Meldung „sprach-agnostisch (doc-only Gate)“ — siehe [Ohne Sprache aufsetzen](#ohne-sprache-aufsetzen-doc-only).)

### Wichtigstes Bedienkonzept

`ai-harness-init` arbeitet in **einem** Schritt und ist **idempotent**: Sie können denselben Aufruf gefahrlos wiederholen. Bei einem zweiten Lauf wird die **werkzeug-eigene Infrastruktur** (Prüf-Konfiguration, Hooks, Regelwerk) auf den mitgelieferten Soll-Stand aufgefrischt (das heilt eventuelle Abweichungen und zieht ein neueres Regelwerk nach), während **von Ihnen gefüllte Dateien** (Ihre Projekt-Dokumente, `README.md`, Ihr Quellcode) **unangetastet** bleiben. Es gibt **keinen** Kollisions-Abbruch und **kein** `--force` — der Re-Lauf ist der normale, sichere Weg, ein Repository zu reparieren oder auf einen neueren Kurs-Stand zu heben.

---

## 4. Aufgaben

Dieser Abschnitt beschreibt die häufigsten Aufgaben Schritt für Schritt.

### Ein neues Projekt aufsetzen

**Voraussetzung:** Ein leeres oder frisch mit `git init` angelegtes Verzeichnis, Docker läuft, Netzwerk ist erreichbar.

**Vorgehen**

1. Wechseln Sie in Ihr Projektverzeichnis:

   ```bash
   cd mein-projekt
   ```

2. Führen Sie das Werkzeug mit Sprache und Projektnamen aus:

   ```bash
   ai-harness-init --lang go --name "Mein Projekt"
   ```

**Ergebnis:** Das Verzeichnis enthält jetzt Regelwerk, Vorlagen, Prüf-Konfiguration und ein Go-Grundgerüst (siehe [Was wird angelegt](#6-was-wird-angelegt)). Der Platzhalter für den Projektnamen ist durch „Mein Projekt“ ersetzt.

**Hinweise:** Der Aufruf braucht **einmalig** Netzwerk (Regelwerk-Download). `--lang` ist **optional** — ohne Sprache setzt das Werkzeug ein rein dokumentgeführtes Repository auf (siehe [Ohne Sprache aufsetzen](#ohne-sprache-aufsetzen-doc-only)). Den Aufruf können Sie gefahrlos wiederholen (siehe [Ein Repository erneut aufsetzen](#ein-repository-erneut-aufsetzen-idempotent)).

### Ohne Projektnamen aufsetzen

**Voraussetzung:** wie oben.

**Vorgehen**

```bash
ai-harness-init --lang go
```

**Ergebnis:** Das Repository wird aufgesetzt, aber der Platzhalter `<Projektname>` bleibt in den Vorlagen stehen. Sie können ihn später von Hand ersetzen. `--name` ist optional.

### Ohne Sprache aufsetzen (doc-only)

**Voraussetzung:** Sie wollen zuerst die Prozess- und Architektur-Dokumente aufsetzen und die Zielsprache **später** entscheiden (empfohlen: „doc führt“ — die Sprache ist eine Architektur-Entscheidung, kein Startargument).

**Vorgehen**

```bash
ai-harness-init --name "Mein Projekt"
```

**Ergebnis:** Das Repository erhält Regelwerk, Vorlagen, Prüf-Konfiguration und die automatischen Schutz-Hooks (Command-Guard) — **aber kein Sprach-Grundgerüst**. `make gates` läuft dokument-only grün (Dokumentations-Prüfung + Regelwerk-Verifikation), ohne Kompilier-/Test-/Linter-Schritt. Ein Sprachmodul fügen Sie später mit `add-lang` hinzu (siehe unten).

### Ein Sprachmodul hinzufügen (`add-lang`)

**Voraussetzung:** Ein bereits aufgesetztes Repository (die zentrale `Makefile` existiert).

**Vorgehen**

```bash
ai-harness-init add-lang go .
```

`<pfad>` ist der Zielort des Moduls; `.` verortet es am Repository-Wurzelverzeichnis. Für ein **Mono-Repo** rufen Sie `add-lang` mehrfach mit verschiedenen Pfaden auf:

```bash
ai-harness-init add-lang go apps/api
ai-harness-init add-lang go apps/web
```

**Ergebnis:** Je Aufruf entstehen das Sprach-Grundgerüst unter `<pfad>`, seine Prüf-Bausteine (`harness/mk/<modul>.mk`) und ein Schutz-Eintrag (`tools/harness/blocked/<sprache>`). Danach fährt `make gates` zusätzlich die Prüfungen des neuen Moduls. Die Abschluss-Zeile lautet z. B.:

```text
ai-harness-init: add-lang go nach apps/api — Skelett + harness/mk/apps-api.mk + tools/harness/blocked/go.
```

**Hinweise:** `--lang <sprache>` beim Aufsetzen ist die Kurzform für „aufsetzen **und** ein `add-lang(<sprache>, .)`“. Der `<pfad>` muss innerhalb des Repositorys liegen (kein absoluter Pfad, kein `..`).

### Ein geschichtetes Grundgerüst wählen (`--arch`)

**Voraussetzung:** wie bei `add-lang`.

Standardmäßig entsteht ein **flaches** Grundgerüst: ein Einstiegspunkt, keine Schichten. Mit `--arch hexslice` entsteht stattdessen ein **geschichtetes** Grundgerüst (HexSlice = hexagonal + vertikale Use-Case-Schnitte):

```bash
ai-harness-init add-lang go apps/api --arch hexslice
```

**Ergebnis — zusätzlich zum flachen Fall:**

- der Code liegt in Schichten: `internal/hexagon/domain/…`, `internal/hexagon/application/<bereich>/<use-case>/…` (mit eigenen `ports/`), `internal/adapters/{inbound,outbound}/…`, dazu `cmd/<binary>/main.go` als Verdrahtungs-Punkt;
- **das Architektur-Gate wird mitgeliefert**: `<pfad>/.a-check.yml` (die Schicht-Regeln) und `a-check.mk` (der Prüf-Baustein). `make gates` fährt es ab sofort mit.

Das Architektur-Gate prüft die **Abhängigkeitsrichtung**: Importe zeigen nur nach innen. Ein Verstoß — etwa ein Import aus der Domain in einen Adapter — lässt `make gates` **rot** werden, mit Datei und Zeile:

```text
internal/hexagon/domain/example/greeting.go:8: core-impurity: Kern importiert app/internal/adapters/outbound/notify
```

**Bei `--arch flat` (dem Standard) wird kein Architektur-Gate angelegt** — es gäbe dort keine Schichten zu prüfen, und ein Gate ohne Prüfbereich wäre eine leere Zusage.

**Wichtig für die Pflege:** `.a-check.yml` gehört Ihnen — ein erneutes Aufsetzen überschreibt sie nicht. Legen Sie einen **weiteren** Use-Case-Schnitt an, tragen Sie ihn dort nach (je ein Eintrag unter `app` und, falls er eigene Ports hat, unter `ports`). Vergessen Sie es, fällt der neue Code unter keine Schicht: importiert er eine, meldet das Gate `wrong-direction` — importiert er keine, bleibt er unbemerkt ungeprüft.

**Grenzen:** `--arch hexslice` liefert derzeit nur der Go-Renderer. `add-lang cpp <pfad> --arch hexslice` endet bewusst mit Exit 2 statt still ein Grundgerüst ohne Schichten anzulegen. Eine unbekannte Architektur endet ebenfalls mit Exit 2 und nennt die verfügbaren Werte.

### Das aufgesetzte Repository prüfen

**Voraussetzung:** Der Aufsetz-Lauf war erfolgreich; Docker läuft.

**Vorgehen**

```bash
make gates
```

**Ergebnis:** Alle Prüfungen laufen durch (Exit-Code 0). Dazu gehören die Dokumentations-Prüfung und die Go-Prüfungen (Kompilieren, Test, Linter). Ein grüner Lauf bestätigt: Das Repository ist aufsetzbereit und korrekt verdrahtet.

**Hinweise:** `make gates` nutzt Docker. Läuft Docker nicht, schlägt die Prüfung mit einer Docker-Fehlermeldung fehl — kein Fehler des Repositorys.

### Ein Repository erneut aufsetzen (idempotent)

**Voraussetzung:** Sie wollen ein bereits aufgesetztes Verzeichnis reparieren (etwa nach einem abgebrochenen Lauf) oder auf einen neueren Kurs-Stand heben.

**Vorgehen** — einfach denselben Aufruf wiederholen:

```bash
ai-harness-init --lang go --name "Mein Projekt"
```

**Ergebnis:** Der Lauf ist **idempotent** (Exit-Code 0). Die werkzeug-eigene Infrastruktur (Prüf-Konfiguration, Hooks, die zentrale `Makefile`, Regelwerk) wird auf den mitgelieferten Soll-Stand **aufgefrischt** — das heilt Abweichungen und zieht ein neueres Regelwerk nach. **Von Ihnen gefüllte Dateien** — die Dokumente unter `spec/`, `README.md`, `AGENTS.md`, Ihr Quellcode im Grundgerüst (`go.mod`, `cmd/app/main.go` …) — bleiben **unangetastet**.

**Hinweise:** Es gibt **kein** `--force` und **keinen** Kollisions-Abbruch mehr (frühere Versionen kannten das). Wollen Sie eine von Ihnen bearbeitete werkzeug-eigene Datei bewusst auf den Ausgangsstand zurücksetzen, löschen Sie sie vor dem Re-Lauf — dann wird sie neu geschrieben.

### Eine andere Kurs-Version verwenden

**Voraussetzung:** Sie möchten das Regelwerk von einem anderen als dem voreingestellten Kurs-Stand beziehen.

**Vorgehen**

```bash
COURSE_TAG=v3.5.2 ai-harness-init --lang go --name "Mein Projekt"
```

**Ergebnis:** Das Regelwerk wird vom angegebenen Kurs-Stand geholt. Ohne die Variable wird der im Werkzeug festgelegte, geprüfte Stand verwendet.

**Hinweise:** Voreingestellte Werte sind bewusst festgelegt (reproduzierbar). Ändern Sie sie nur, wenn Sie einen bestimmten Stand brauchen. Siehe [Konfiguration](#5-konfiguration).

### Die Go-Version des Grundgerüsts festlegen

**Voraussetzung:** Das erzeugte Go-Grundgerüst soll eine bestimmte Go-Version verwenden.

**Vorgehen**

```bash
SKEL_GO_VERSION=1.26.4 ai-harness-init --lang go --name "Mein Projekt"
```

**Ergebnis:** Das erzeugte Grundgerüst (`Dockerfile`, `go.mod`) verwendet die angegebene Go-Version. Ohne die Variable gilt die festgelegte Standard-Version.

---

## 5. Konfiguration

### Aufruf-Optionen (Aufsetzen)

| Option | Pflicht | Bedeutung |
|---|---|---|
| `--lang <sprache>` | nein | Zielsprache des Grundgerüsts (Kurzform für „aufsetzen + `add-lang(<sprache>, .)`“). Ohne sie: dokument-only. Derzeit unterstützt: `go`, `cpp` (C++ per CMake + clang-tidy). |
| `--arch <arch>` | nein | Bauform des Grundgerüsts: `flat` (Standard) oder `hexslice` (geschichtet, mit Architektur-Gate). Wirkt nur zusammen mit `--lang`. Siehe [Ein geschichtetes Grundgerüst wählen](#ein-geschichtetes-grundgerüst-wählen---arch). |
| `--name <name>` | nein | Projektname; ersetzt den Platzhalter `<Projektname>` in den Vorlagen. |
| `-h`, `--help` | nein | Hilfe anzeigen und beenden. |

Ein `--force` gibt es **nicht** — der Re-Lauf ist idempotent (siehe [Ein Repository erneut aufsetzen](#ein-repository-erneut-aufsetzen-idempotent)).

### Subkommando `add-lang`

```bash
ai-harness-init add-lang <sprache> <pfad>
```

Fügt einem bereits aufgesetzten Repository ein Sprachmodul hinzu — **wiederholbar** (Mono-Repo), auch mit gemischten Sprachen. Beide Positions-Argumente sind Pflicht: `<sprache>`, `<pfad>` (Zielort im Repository; `.` = Wurzel). Optional folgt **nach** ihnen `--arch <arch>` (`flat` oder `hexslice`); die Bauform ist je Modul frei wählbar, ein Mono-Repo darf beide mischen. Siehe [Ein Sprachmodul hinzufügen](#ein-sprachmodul-hinzufügen-add-lang) und [Ein geschichtetes Grundgerüst wählen](#ein-geschichtetes-grundgerüst-wählen---arch).

### Umgebungsvariablen

Alle Umgebungsvariablen sind **optional**. Ohne sie gelten festgelegte, reproduzierbare Standardwerte — Sie brauchen sie nur, um bewusst abzuweichen.

| Variable | Bedeutung |
|---|---|
| `COURSE_TAG` | Kurs-Version für das Regelwerk und die Vorlagen. |
| `SKEL_GO_VERSION` | Go-Version des erzeugten Go-Grundgerüsts. |
| `SKEL_CPP_VERSION` | Ubuntu-Basis-Tag des erzeugten C++-Grundgerüsts (bestimmt Compiler/CMake/clang-tidy). Allgemein: `SKEL_<SPRACHE>_VERSION` setzt die Toolchain-Version je Sprache. |
| `BASELINE_SHA256` | Erwartete Prüfsumme des heruntergeladenen Regelwerk-Pakets. |
| `DCHECK_IMAGE` | Abweichende Referenz für das Dokumentations-Prüf-Image. |
| `DCHECK_DIGEST` | Abweichende Prüfsumme (Digest) des Prüf-Images; sticht die Referenz. |
| `A_CHECK_IMAGE` | Abweichende Referenz für das Architektur-Prüf-Image (nur bei `--arch hexslice` genutzt). |
| `A_CHECK_DIGEST` | Abweichende Prüfsumme (Digest) des Architektur-Prüf-Images; sticht die Referenz. |

Beispiel mit mehreren Variablen:

```bash
COURSE_TAG=v3.5.2 SKEL_GO_VERSION=1.26.4 ai-harness-init --lang go --name "Mein Projekt"
```

---

## 6. Was wird angelegt

Der Bootstrap läuft in **Phasen**: Ein **Aufsetzen ohne Sprache** legt die dokument-geführte Basis an; ein **Sprachmodul** kommt danach per `--lang <sprache>` (Kurzform beim Aufsetzen) oder jederzeit per `add-lang <sprache> <pfad>` dazu — wiederholbar zu einem Mono-Repo. Entsprechend zeigen wir beide Fälle.

### Phase 1 — Aufsetzen ohne Sprache (dokument-only)

`ai-harness-init --name "Mein Projekt"` (ohne `--lang`) legt die sprach-unabhängige Basis an (leere Prozess-Ordner werden mit einer `.gitkeep`-Datei gehalten, damit `git` sie behält):

```text
mein-projekt/
├── AGENTS.md                 Regeln und Verweise für KI-Agenten (Vorlage, ausfüllen)
├── README.md                 Projekt-Überblick
├── Makefile                  Einstiegspunkt: make gates …
├── .d-check.yml              Konfiguration der Dokumentations-Prüfung
├── d-check.mk                Prüf-Ziel der Dokumentations-Prüfung (make docs-check)
├── spec/                     Anforderungen und Architektur (Vorlagen)
├── harness/                  Einstiegs- und Konventions-Dokumente (Vorlagen)
│   └── mk/                   Prüf-Bausteine: Doc-Gate, Regelwerk-Prüfung, Schutz-Hooks
├── docs/plan/                Planung: Architektur-Entscheidungen, Slices, Roadmap
├── tools/harness/            Hilfsskripte des Repositorys
├── .claude/                  Schutz-Hooks (Command-Guard, Gate-Nachweis) + Arbeitsabläufe
└── .harness/baseline/        Mitgeliefertes Regelwerk und Vorlagen (netzunabhängig)
```

Schon hier läuft `make gates` **grün** — dokument-only (Dokumentations-Prüfung + Regelwerk-Integrität), **ohne** Code-Gate und **ohne** Sprach-Grundgerüst.

### Phase 2 — ein Sprachmodul hinzufügen

`--lang <sprache>` (beim Aufsetzen) oder `add-lang <sprache> <pfad>` (jederzeit danach) legt **zusätzlich** die Sprach-Dateien an, samt Prüf-Baustein `harness/mk/<modul>.mk`. Sie unterscheiden sich je Sprache:

- **Go:** `Dockerfile`, `go.mod`, `.golangci.yml`, `cmd/app/main.go`
- **C++:** `Dockerfile`, `CMakeLists.txt`, `src/main.cpp`, `tests/` (netzloser CTest) und `.clang-tidy`

Am Wurzelverzeichnis (`--lang go` bzw. `add-lang go .`) liegen sie neben den Basis-Dateien; in einem **Mono-Repo** (mehrere `add-lang`-Läufe mit verschiedenen `<pfad>`) je Modul ein solcher Satz unter seinem `<pfad>`, auch mit gemischten Sprachen. Erst mit einem Sprachmodul fährt `make gates` **zusätzlich** die Code-Gates (lint/build/test in Docker).

Mit `--arch hexslice` sieht der Code-Teil anders aus (die Bau-Dateien bleiben gleich): statt eines einzelnen Einstiegspunkts entstehen die Schichten `internal/hexagon/{domain,application}`, `internal/adapters/{inbound,outbound}` und `cmd/<binary>/main.go` — **plus** das Architektur-Gate `<pfad>/.a-check.yml` und `a-check.mk`. Bei `flat` (dem Standard) entsteht keines von beidem. Siehe [Ein geschichtetes Grundgerüst wählen](#ein-geschichtetes-grundgerüst-wählen---arch).

Die Dateien mit der Endung `.template.md` unter `.harness/baseline/` sind **Vorlagen**: Sie kopieren sie bei Bedarf und füllen sie aus (z. B. für eine neue Architektur-Entscheidung). Die Prozess-Regeln erklären, wann welche Vorlage zum Einsatz kommt.

---

## 7. Fehlerbehebung

Alle Fehler von `ai-harness-init` beginnen auf der Fehlerausgabe mit `Fehler:` und liefern einen von Null verschiedenen Exit-Code (siehe [Anhang](#10-anhang)).

### Fehler: `unbekannte Sprache "…"; verfuegbar: cpp, go`

**Ursache:** Sie haben eine Sprache angegeben, für die es (noch) kein Grundgerüst gibt.

**Lösung:** Verwenden Sie eine der aufgelisteten Sprachen. Derzeit sind das `go` und `cpp`:

```bash
ai-harness-init --lang cpp
```

### Fehler: `kein Aggregator (Makefile) — zuerst ai-harness-init (Init) im Repo laufen lassen`

**Ursache:** Sie haben `add-lang` in einem Verzeichnis aufgerufen, das noch **nicht** aufgesetzt ist (es fehlt die `Makefile`, die das Sprachmodul einbindet).

**Lösung:** Setzen Sie das Repository zuerst auf (mit oder ohne Sprache), dann `add-lang`:

```bash
ai-harness-init --name "Mein Projekt"
ai-harness-init add-lang go apps/api
```

### Fehler: `<pfad> muss innerhalb des Repos liegen (kein absoluter Pfad, kein ..)`

**Ursache:** Sie haben `add-lang` einen Pfad gegeben, der aus dem Repository hinausführt (absolut oder mit `..`).

**Lösung:** Verwenden Sie einen Pfad **innerhalb** des Repositorys, z. B. `.`, `apps/api`.

### Der Lauf hängt oder bricht mit einem Docker-Fehler ab

**Ursache:** Docker läuft nicht oder ist nicht erreichbar. `ai-harness-init` ruft Docker auf, um die Prüf-Konfiguration zu erzeugen.

**Lösung:** Starten Sie Docker und prüfen Sie mit `docker ps`, dass es bedienbar ist. Wiederholen Sie den Aufruf.

### Der Lauf bricht mit einem Netzwerk- oder Download-Fehler ab

**Ursache:** Der **erste** Lauf lädt das Regelwerk aus dem Netz. Ohne Verbindung schlägt er fehl.

**Lösung:** Stellen Sie eine Internet-Verbindung sicher und wiederholen Sie den Aufruf. Nach einem erfolgreichen ersten Lauf ist das Repository netzunabhängig.

### `make gates` schlägt im aufgesetzten Repository fehl

**Ursache:** In aller Regel läuft Docker nicht — die Prüfungen sind Docker-basiert. Ein frisch aufgesetztes Repository ist andernfalls grün.

**Lösung:** Docker starten und `make gates` erneut ausführen. Bleibt der Fehler bestehen, prüfen Sie, ob Sie erzeugte Dateien verändert haben.

---

## 8. Häufige Fragen (FAQ)

**Welche Sprachen werden unterstützt?**
Derzeit `go` und `cpp` (C++). Das Werkzeug ist auf weitere Sprachen ausgelegt; sie kommen ohne Änderung der Bedienung hinzu. Die jeweils aktuelle Liste zeigt eine unbekannte Sprache in ihrer Fehlermeldung.

**Muss ich Go installieren?**
Nein. Sowohl das Bauen des Werkzeugs als auch die Prüfungen im aufgesetzten Repository laufen über Docker.

**Braucht das Werkzeug dauerhaft Internet?**
Nein, nur **einmalig** beim ersten Aufsetzen (Regelwerk-Download). Danach arbeitet Ihr Repository netzunabhängig.

**Kann ich denselben Ordner mehrfach aufsetzen?**
Ja — der Aufruf ist **idempotent** (Exit-Code 0). Ein zweiter Lauf frischt die werkzeug-eigene Infrastruktur auf und lässt Ihre eigenen Dateien unangetastet. Genau so reparieren Sie ein Repository oder heben es auf einen neueren Kurs-Stand.

**Wie füge ich eine zweite Sprache oder ein weiteres Modul hinzu?**
Mit `ai-harness-init add-lang <sprache> <pfad>`. Der Befehl ist wiederholbar; mehrere Aufrufe mit verschiedenen Pfaden ergeben ein Mono-Repo. Siehe [Ein Sprachmodul hinzufügen](#ein-sprachmodul-hinzufügen-add-lang).

**Gibt es ein fertiges Download-Binary?**
Ja, ab `v0.1.0` — für sechs Plattformen (Linux, macOS, Windows × Intel/AMD und ARM). Das ist der empfohlene Weg, siehe [Installation](#2-installation-und-zugriff). Den Bau aus dem Quellcode brauchen Sie nur für einen Stand ohne Versions-Kennzeichnung.

**Verändert `ai-harness-init` meine bestehenden Dateien?**
Ihre gefüllten Dateien (Dokumente, `README.md`, Ihr Quellcode) **nicht** — vorhandene Dateien dieser Art werden nie überschrieben. Die **werkzeug-eigene** Infrastruktur (Prüf-Konfiguration, Hooks, Regelwerk) wird bei jedem Lauf neu auf den Soll-Stand geschrieben; hatten Sie eine solche Datei von Hand geändert, wird die Änderung beim Re-Lauf überschrieben.

---

## 9. Glossar

| Begriff | Bedeutung |
|---|---|
| **Harness** | Das Prozess-Gerüst aus Regeln, Vorlagen und Prüfungen, das `ai-harness-init` in Ihr Repository einsetzt. |
| **Gate** | Eine automatische Prüfung, die grün (bestanden) oder rot (fehlgeschlagen) ist. `make gates` fährt alle Gates. |
| **Bootstrap** | Das Aufsetzen eines Repositorys mit dem Harness — das, was `ai-harness-init` tut. Wiederholbar (idempotent). |
| **`add-lang`** | Das Subkommando, das einem aufgesetzten Repository ein Sprachmodul hinzufügt — wiederholbar (Mono-Repo). |
| **idempotent** | Ein wiederholter Aufruf hinterlässt denselben Zustand: werkzeug-eigene Dateien werden auf den Soll-Stand aufgefrischt, Ihre gefüllten Dateien bleiben unberührt (kein Kollisions-Abbruch, kein `--force`). |
| **Regelwerk / Baseline** | Der festgelegte Kurs-Stand aus Prozess-Regeln und Vorlagen, den das Werkzeug in Ihr Repository legt. |
| **Grundgerüst (Skelett)** | Das minimale, lauffähige Sprach-Layout (bei `go`: `Dockerfile`, `Makefile`, `go.mod`, Beispiel-Code), das die Prüfungen bedienen. |
| **Doc-Gate** | Die Dokumentations-Prüfung (Ziel `make docs-check`): prüft Verweise, Anker und Kennungen in den Markdown-Dateien. |
| **Aggregator (`Makefile`)** | Die zentrale `Makefile` im Repository, die alle Prüf-Bausteine einbindet; `make gates` fährt darüber alle Prüfungen. Erscheint so in der Abschluss-Ausgabe des Werkzeugs. |
| **Prüf-Baustein (Fragment)** | Eine kleine `make`-Datei (`harness/mk/*.mk`), die je eine Prüfung beisteuert; die zentrale `Makefile` bindet sie ein. |
| **Command-Guard / Durchsetzung** | Automatische Schutz-Hooks unter `.claude/`, die im aufgesetzten Repo riskante Befehle abfangen (z. B. Toolchains außerhalb von Docker). Erscheint als „Durchsetzung“ in der Abschluss-Ausgabe. |
| **Vorlage (`.template.md`)** | Eine Datei zum Kopieren-und-Ausfüllen für wiederkehrende Artefakte (z. B. eine Architektur-Entscheidung). |

---

## 10. Anhang

### Exit-Codes

| Code | Bedeutung |
|---|---|
| `0` | Erfolg (auch bei einem idempotenten Re-Lauf). |
| `2` | Aufruf-Fehler (z. B. unbekannte Sprache, unbekannte Option, `add-lang` ohne `<sprache>`/`<pfad>` oder mit einem Pfad außerhalb des Repositorys). Ihr Verzeichnis bleibt unverändert. |
| `1` | Laufzeit-Fehler beim Aufsetzen (z. B. Docker- oder Netzwerk-Problem, oder `add-lang` ohne vorher aufgesetztes Repository). |

### Grenzen und Hinweise

* Im Quellcode-Repository liegt **kein** eingecheckt vorliegendes Binary und kein `run`-Ziel. Fertige Programme gibt es **an den Releases** (ab `v0.1.0`); wer aus dem Quellcode baut, arbeitet gegen den Repo-Stand und hat dann keine Versions-Kennzeichnung.
* Der erste Lauf benötigt Netzwerk; danach ist das Repository netzunabhängig.
* `ai-harness-init` und die Prüfungen im Zielrepository benötigen Docker.
* Voreingestellte Versionen (Kurs-Stand, Go-Version, Prüf-Image) sind festgelegt und reproduzierbar; Abweichungen nur über die Umgebungsvariablen aus [Konfiguration](#5-konfiguration).
* **Sicherheit:** Das Regelwerk wird beim Download gegen eine feste Prüfsumme verifiziert (`BASELINE_SHA256`); das aufgesetzte Repository fängt riskante Befehle über den Command-Guard ab und lässt die Prüfungen nur in Docker laufen.

### Support und Kontakt

* Quellcode und Fehlermeldungen: das Projekt-Repository `ai-harness-init` (pt9912).
* Lizenz: MIT.

---

## 11. Änderungshistorie

| Handbuch-Version | Stand | Änderung |
|---|---|---|
| 1.6 | 2026-07-26 | `make artifact DEST=<ordner>` legt den Zielordner jetzt selbst an. Bis einschließlich `v0.1.0` brach der Befehl mit `invalid output path: directory … does not exist` ab, wenn der Ordner fehlte — obwohl die Anleitung genau diesen Aufruf vorschreibt (von einem Nutzer gemeldet). Der Hinweis im Installations-Abschnitt sagt das jetzt; die Versions-Abgrenzung steht hier statt im Fließtext. |
| 1.5 | 2026-07-26 | **Erstes Release `v0.1.0`**: fertige Programme für sechs Plattformen (Linux · macOS · Windows × Intel/AMD · ARM) sind der empfohlene Weg; §2 in Weg A (Download) und Weg B (aus dem Quellcode bauen) geteilt, mit Dateitabelle, Suchpfad-Hinweis und macOS-Quarantäne-Hinweis. Neuer Kasten „Was wo geprüft wird": der vollständige Durchlauf läuft auf Linux/Intel-AMD, beim Release wird auf allen sechs Dateien nur der **Start** geprüft. FAQ, Anhang und Systemanforderungen nachgezogen; FAQ-Sprachliste um `cpp` korrigiert. |
| 1.4 | 2026-07-25 | **Bauform `--arch`** (slice-045b/046): `hexslice` erzeugt ein geschichtetes Grundgerüst und liefert das **Architektur-Gate** (`.a-check.yml` + `a-check.mk`) mit, `flat` (Standard) nicht. Neuer Aufgaben-Abschnitt samt Pflege-Hinweis für zusätzliche Use-Case-Schnitte, Optionstabelle, `add-lang`-Signatur, `A_CHECK_IMAGE`/`A_CHECK_DIGEST` und Phase-2-Beschreibung nachgezogen. Nachzug: das Handbuch kannte die Achse seit zwei Slices nicht. |
| 1.3 | 2026-07-23 | Zweite Zielsprache **C++** (slice-039): `--lang cpp` und `add-lang cpp <pfad>` erzeugen ein CMake-Grundgerüst (Dockerfile-Stages build/test/lint mit CMake + CTest + clang-tidy, netzloser Test). Optionstabelle, `SKEL_CPP_VERSION`, Sprach-Datei-Liste, Fehlermeldung und FAQ nachgezogen. Gemischt-sprachige Mono-Repos möglich. |
| 1.2 | 2026-07-23 | Sprach-Review gegen den Benutzerhandbuch-Standard: Entwicklerbegriffe geglättet (Aggregator → zentrale `Makefile`, Durchsetzung → Schutz-Hooks, Doc-Chain → Projekt-Dokumente, „skip-if-present“/„kanonisch“/„vendored“ plain); die in der Werkzeug-Ausgabe sichtbaren Begriffe (Aggregator, Durchsetzung, Prüf-Baustein) ins Glossar aufgenommen; Sicherheits- und Versions-Hinweis im Anhang ergänzt. |
| 1.1 | 2026-07-23 | Phasierter Bootstrap (welle-05): `--lang` optional (dokument-only Init), neues `add-lang`-Subkommando (Mono-Repo), idempotenter Re-Lauf. `--force` entfernt; Kollisions-Abbruch-Verhalten und die zugehörigen Fehler/FAQ/Exit-Codes ersetzt. |
| 1.0 | 2026-07-22 | Erste Fassung. Deckt den vollständigen Bootstrap (`--lang go`), Konfiguration, Fehlerbehebung, FAQ und Glossar ab. |
