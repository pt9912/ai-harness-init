# Benutzerhandbuch: ai-harness-init

**Handbuch-Version:** 1.0
**Software-Stand:** Entwicklungsstand M2 — vollständiger Bootstrap; Zielsprache `go` (weitere folgen). Noch keine vorgefertigten Release-Binaries.
**Stand:** 2026-07-22
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

* Ein Betriebssystem mit Docker (Linux oder macOS werden empfohlen).
* `git` und GNU `make` auf dem Pfad.
* Beim ersten Aufruf: Internet-Zugang.

### Das Werkzeug bereitstellen

Es gibt derzeit **noch keine** vorgefertigten Download-Binaries. Sie bauen das Programm einmalig aus dem Quellcode — das geschieht komplett in Docker, Sie brauchen dafür keine Go-Installation.

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

Im Ordner **bin** liegt das ausführbare Programm `ai-harness-init`. Kopieren Sie es bei Bedarf an eine Stelle auf Ihrem Pfad (zum Beispiel nach `~/.local/bin`), damit Sie es überall als `ai-harness-init` aufrufen können. Das Handbuch verwendet ab hier den kurzen Aufruf `ai-harness-init`.

> **Hinweis:** `make artifact DEST=./bin` verlangt die Angabe `DEST`. Ohne sie bricht der Befehl mit einer klaren Meldung ab.

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
ai-harness-init: Bootstrap (Skelett "go" verdrahtet + Baseline v3.5.0 vendored + Doc-Gate + Template-Baseline) — --lang=go.
```

Das bedeutet: Regelwerk und Vorlagen liegen im Repository, die Prüfungen sind verdrahtet, und ein lauffähiges Go-Grundgerüst ist eingebaut. `make gates` läuft danach ohne Fehler durch.

### Wichtigstes Bedienkonzept

`ai-harness-init` arbeitet in **einem** Schritt und ist **defensiv**: Findet es eine Datei, die es anlegen würde, bereits vor, **schreibt es gar nichts** und meldet den Konflikt — statt ein halb aufgesetztes Repository zu hinterlassen. Wenn Sie vorhandene Dateien bewusst ersetzen wollen, verwenden Sie `--force` (siehe [Aufgaben](#4-aufgaben)).

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

**Hinweise:** Der Aufruf braucht **einmalig** Netzwerk (Regelwerk-Download). Bricht er ab, weil eine Datei bereits existiert, siehe [Bestehende Dateien ersetzen](#bestehende-dateien-ersetzen).

### Ohne Projektnamen aufsetzen

**Voraussetzung:** wie oben.

**Vorgehen**

```bash
ai-harness-init --lang go
```

**Ergebnis:** Das Repository wird aufgesetzt, aber der Platzhalter `<Projektname>` bleibt in den Vorlagen stehen. Sie können ihn später von Hand ersetzen. `--name` ist optional.

### Das aufgesetzte Repository prüfen

**Voraussetzung:** Der Aufsetz-Lauf war erfolgreich; Docker läuft.

**Vorgehen**

```bash
make gates
```

**Ergebnis:** Alle Prüfungen laufen durch (Exit-Code 0). Dazu gehören die Dokumentations-Prüfung und die Go-Prüfungen (Kompilieren, Test, Linter). Ein grüner Lauf bestätigt: Das Repository ist aufsetzbereit und korrekt verdrahtet.

**Hinweise:** `make gates` nutzt Docker. Läuft Docker nicht, schlägt die Prüfung mit einer Docker-Fehlermeldung fehl — kein Fehler des Repositorys.

### Bestehende Dateien ersetzen

**Voraussetzung:** Sie wollen ein Verzeichnis erneut aufsetzen, in dem bereits Dateien aus einem früheren Lauf liegen.

**Vorgehen**

```bash
ai-harness-init --lang go --name "Mein Projekt" --force
```

**Ergebnis:** Vorhandene Zieldateien werden **überschrieben**. Ohne `--force` bricht der Lauf ab, sobald er die erste Kollision findet, und lässt Ihr Verzeichnis unverändert.

**Hinweise:** `--force` überschreibt ohne Rückfrage. Sichern Sie eigene Änderungen an den erzeugten Dateien vorher (z. B. per `git commit`).

### Eine andere Kurs-Version verwenden

**Voraussetzung:** Sie möchten das Regelwerk von einem anderen als dem voreingestellten Kurs-Stand beziehen.

**Vorgehen**

```bash
COURSE_TAG=v3.5.0 ai-harness-init --lang go --name "Mein Projekt"
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

### Aufruf-Optionen

| Option | Pflicht | Bedeutung |
|---|---|---|
| `--lang <sprache>` | ja | Zielsprache des Grundgerüsts. Derzeit unterstützt: `go`. |
| `--name <name>` | nein | Projektname; ersetzt den Platzhalter `<Projektname>` in den Vorlagen. |
| `--force` | nein | Vorhandene Zieldateien überschreiben. |
| `-h`, `--help` | nein | Hilfe anzeigen und beenden. |

### Umgebungsvariablen

Alle Umgebungsvariablen sind **optional**. Ohne sie gelten festgelegte, reproduzierbare Standardwerte — Sie brauchen sie nur, um bewusst abzuweichen.

| Variable | Bedeutung |
|---|---|
| `COURSE_TAG` | Kurs-Version für das Regelwerk und die Vorlagen. |
| `SKEL_GO_VERSION` | Go-Version des erzeugten Grundgerüsts. |
| `BASELINE_SHA256` | Erwartete Prüfsumme des heruntergeladenen Regelwerk-Pakets. |
| `DCHECK_IMAGE` | Abweichende Referenz für das Dokumentations-Prüf-Image. |
| `DCHECK_DIGEST` | Abweichende Prüfsumme (Digest) des Prüf-Images; sticht die Referenz. |

Beispiel mit mehreren Variablen:

```bash
COURSE_TAG=v3.5.0 SKEL_GO_VERSION=1.26.4 ai-harness-init --lang go --name "Mein Projekt"
```

---

## 6. Was wird angelegt

Nach einem erfolgreichen Lauf enthält Ihr Verzeichnis die folgende Struktur (leere Prozess-Ordner werden mit einer `.gitkeep`-Datei gehalten, damit `git` sie behält):

```text
mein-projekt/
├── AGENTS.md                 Regeln und Verweise für KI-Agenten (Vorlage, ausfüllen)
├── README.md                 Projekt-Überblick
├── Makefile                  Einstiegspunkt: make gates, lint, build, test …
├── Dockerfile                Bau- und Prüf-Stufen (Docker-only)
├── go.mod                    Go-Modul-Definition
├── .golangci.yml             Konfiguration des Go-Linters
├── .d-check.yml              Konfiguration der Dokumentations-Prüfung
├── d-check.mk                Prüf-Ziel der Dokumentations-Prüfung (make docs-check)
├── cmd/app/main.go           Lauffähiges Beispiel-Grundgerüst
├── spec/                     Anforderungen und Architektur (Vorlagen)
├── harness/                  Einstiegs- und Konventions-Dokumente (Vorlagen)
├── docs/plan/                Planung: Architektur-Entscheidungen, Slices, Roadmap
├── tools/harness/            Hilfsskripte des Repositorys
└── .harness/baseline/        Vendored Regelwerk und Vorlagen (netzunabhängig)
```

Die Dateien mit der Endung `.template.md` unter `.harness/baseline/` sind **Vorlagen**: Sie kopieren sie bei Bedarf und füllen sie aus (z. B. für eine neue Architektur-Entscheidung). Die Prozess-Regeln erklären, wann welche Vorlage zum Einsatz kommt.

---

## 7. Fehlerbehebung

Alle Fehler von `ai-harness-init` beginnen auf der Fehlerausgabe mit `Fehler:` und liefern einen von Null verschiedenen Exit-Code (siehe [Anhang](#10-anhang)).

### Fehler: `--lang ist erforderlich`

**Ursache:** Sie haben `--lang` nicht angegeben. Das Werkzeug weiß nicht, welches Grundgerüst es erzeugen soll.

**Lösung:** Geben Sie eine Sprache an:

```bash
ai-harness-init --lang go --name "Mein Projekt"
```

### Fehler: `unbekannte Sprache "…"; verfuegbar: go`

**Ursache:** Sie haben eine Sprache angegeben, für die es (noch) kein Grundgerüst gibt.

**Lösung:** Verwenden Sie eine der aufgelisteten Sprachen. Derzeit ist das `go`:

```bash
ai-harness-init --lang go
```

### Fehler: `… existiert bereits (--force zum Ueberschreiben)`

**Ursache:** Im Zielverzeichnis liegt bereits eine Datei, die das Werkzeug anlegen würde. Zum Schutz Ihrer Daten wird **nichts** geschrieben.

**Lösung:** Entweder in ein leeres Verzeichnis wechseln, oder — wenn Sie bewusst ersetzen wollen — `--force` verwenden:

```bash
ai-harness-init --lang go --name "Mein Projekt" --force
```

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
Derzeit `go`. Das Werkzeug ist auf weitere Sprachen ausgelegt; sie kommen ohne Änderung der Bedienung hinzu. Die jeweils aktuelle Liste zeigt eine unbekannte Sprache in ihrer Fehlermeldung.

**Muss ich Go installieren?**
Nein. Sowohl das Bauen des Werkzeugs als auch die Prüfungen im aufgesetzten Repository laufen über Docker.

**Braucht das Werkzeug dauerhaft Internet?**
Nein, nur **einmalig** beim ersten Aufsetzen (Regelwerk-Download). Danach arbeitet Ihr Repository netzunabhängig.

**Kann ich denselben Ordner mehrfach aufsetzen?**
Nur mit `--force`. Ohne diese Option bricht der Lauf bei der ersten vorhandenen Datei ab und lässt Ihr Verzeichnis unverändert.

**Gibt es ein fertiges Download-Binary?**
Derzeit nicht. Sie bauen das Programm einmalig aus dem Quellcode (siehe [Installation](#2-installation-und-zugriff)) — komplett in Docker, ohne lokale Go-Installation.

**Verändert `ai-harness-init` meine bestehenden Dateien?**
Nein, außer Sie verwenden `--force`. Ohne `--force` schreibt es nichts, sobald es eine Kollision entdeckt.

---

## 9. Glossar

| Begriff | Bedeutung |
|---|---|
| **Harness** | Das Prozess-Gerüst aus Regeln, Vorlagen und Prüfungen, das `ai-harness-init` in Ihr Repository einsetzt. |
| **Gate** | Eine automatische Prüfung, die grün (bestanden) oder rot (fehlgeschlagen) ist. `make gates` fährt alle Gates. |
| **Bootstrap** | Das einmalige Aufsetzen eines Repositorys mit dem Harness — das, was `ai-harness-init` tut. |
| **Regelwerk / Baseline** | Der festgelegte Kurs-Stand aus Prozess-Regeln und Vorlagen, den das Werkzeug in Ihr Repository legt. |
| **Grundgerüst (Skelett)** | Das minimale, lauffähige Sprach-Layout (bei `go`: `Dockerfile`, `Makefile`, `go.mod`, Beispiel-Code), das die Prüfungen bedienen. |
| **Doc-Gate** | Die Dokumentations-Prüfung (Ziel `make docs-check`): prüft Verweise, Anker und Kennungen in den Markdown-Dateien. |
| **Vorlage (`.template.md`)** | Eine Datei zum Kopieren-und-Ausfüllen für wiederkehrende Artefakte (z. B. eine Architektur-Entscheidung). |

---

## 10. Anhang

### Exit-Codes

| Code | Bedeutung |
|---|---|
| `0` | Erfolg. |
| `2` | Aufruf-Fehler (z. B. fehlendes `--lang`, unbekannte Sprache, unbekannte Option). Ihr Verzeichnis bleibt unverändert. |
| `1` | Laufzeit-Fehler beim Aufsetzen (z. B. Datei-Kollision ohne `--force`, Docker- oder Netzwerk-Problem). |

### Grenzen und Hinweise

* Es gibt **kein** eingecheckt vorliegendes Binary und kein `run`-Ziel; Sie bauen das Werkzeug aus dem Quellcode.
* Der erste Lauf benötigt Netzwerk; danach ist das Repository netzunabhängig.
* `ai-harness-init` und die Prüfungen im Zielrepository benötigen Docker.
* Voreingestellte Versionen (Kurs-Stand, Go-Version, Prüf-Image) sind festgelegt und reproduzierbar; Abweichungen nur über die Umgebungsvariablen aus [Konfiguration](#5-konfiguration).

### Support und Kontakt

* Quellcode und Fehlermeldungen: das Projekt-Repository `ai-harness-init` (pt9912).
* Lizenz: MIT.

---

## 11. Änderungshistorie

| Handbuch-Version | Stand | Änderung |
|---|---|---|
| 1.0 | 2026-07-22 | Erste Fassung. Deckt den vollständigen Bootstrap (`--lang go`), Konfiguration, Fehlerbehebung, FAQ und Glossar ab. |
