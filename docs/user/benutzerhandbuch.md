# Benutzerhandbuch: ai-harness-init

**Software-Stand:** `v0.2.4` — **vorgefertigte Programme für sechs Plattformen** (linux · macos · windows × amd64 · arm64). Inhaltlich: **phasierter** Bootstrap (Init sprach-agnostisch, `--lang` optional; Sprachmodule per `add-lang`, wiederholbar/Mono-Repo; **idempotenter** Re-Lauf) und **Bauform-Achse** `--arch` (`flat`, `hexagonal` oder `hexslice`; bei den beiden geschichteten kommt das Architektur-Gate mit). Zielsprachen `go` und `cpp`, beide auch mit `hexslice`; `hexagonal` liefert heute der Go-Renderer. Vier Betriebs-Operationen beschreibt [Betriebs-Operationen](#betriebs-operationen). Die geschichtete Bauform benennt Adapter- und Ports-Ordner nach ihren Rollen ([`ADR-0060`](../plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md), `Accepted`: `driving`/`driven`, `ports_inbound`/`ports_outbound` — siehe [Ein geschichtetes Grundgerüst wählen](#ein-geschichtetes-grundgerüst-wählen---arch)); das veröffentlichte `v0.2.4` trägt diese Form.
**Stand:** 2026-09-25
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

Es gibt **drei Wege**. Empfohlen ist der **Download** — fertige Programme für sechs Plattformen; **aktuell ausgeliefert wird `v0.2.4`**. Den Bau aus dem Quellcode brauchen Sie nur, wenn Sie einen Stand **ohne** Versions-Kennzeichnung verwenden wollen. Für macOS und Linux steht der dritte Weg über das **Homebrew-Tap** bereit (siehe [Weg C](#weg-c--über-ein-homebrew-tap-macos-linux)).

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

> **Hinweis für Windows:** Die Programme werden **nicht signiert** — der Release-Lauf hat keinen Signier-Schritt. Windows kann den ersten Start deshalb mit einer Warnung unterbrechen. Was genau angezeigt wird, hängt von Ihrer Windows-Version und Ihren Sicherheitseinstellungen ab; hier läuft kein Windows, also steht hier auch kein Dialog-Wortlaut, den niemand nachgeprüft hat.

**Ergebnis**

Liegt der Ordner in Ihrem Suchpfad, ist das Programm unter dem kurzen Namen `ai-harness-init` aufrufbar. **Das Handbuch verwendet ab hier diesen kurzen Aufruf** — das gilt für beide Wege.

Welche Fassung das Programm trägt, meldet `ai-harness-init --version` — die Fassung des Releases, aus dem Sie geladen haben; der Digest bleibt der eindeutige Beleg gegen die `SHA256SUMS` desselben Releases.

Trägt ein Programm keine Fassung — etwa ein Bau ohne Release-Injektion —, meldet `ai-harness-init --version` `ai-harness-init: keine Fassung injiziert — dieser Bau traegt keinen geschnittenen Tag; die Fassung kommt nur mit einem Release-Bau.` und bricht mit **Exit 2** ab.

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

> **Hinweis:** Weg B baut den Stand, den Sie geklont haben (Schritt 1 holt den aktuellen Entwicklungsstand, nicht die veröffentlichte Version) — die Angaben hier beziehen sich darauf. `make artifact DEST=./bin` verlangt die Angabe `DEST`. Ohne sie bricht der Befehl mit einer klaren Meldung ab. Den Zielordner müssen Sie **nicht** vorher anlegen — er wird erstellt, falls er fehlt.

> **Hinweis:** Dieser Bau trägt **keine** Fassung: `ai-harness-init --version` meldet `ai-harness-init: keine Fassung injiziert — dieser Bau traegt keinen geschnittenen Tag; die Fassung kommt nur mit einem Release-Bau.` und bricht mit **Exit 2** ab. Die Fassungs-Kennzeichnung gehört zum Release-Bau (Weg A und Weg C) — am Quell-Bau ist der Fehlt-Fall der dokumentierte Zustand.

#### Weg C — über ein Homebrew-Tap (macOS, Linux)

Das Tap-Repository [`pt9912/homebrew-ai-harness-init`](https://github.com/pt9912/homebrew-ai-harness-init) trägt die Formel `ai-harness-init`; sie wird je Release-Schnitt aus dem Formel-Asset desselben Schnitts nachgezogen — ihr Skeleton liegt versioniert im Quellcode unter `harness/tools/homebrew-formula.rb.tmpl` und wird je Schnitt mit dessen Version und den vier dafür relevanten Plattform-Prüfsummen befüllt (Linux/macOS × Intel-AMD/ARM).

Homebrew lädt das fertige Programm desselben Releases herunter und installiert es — die Fassung reist mit: `ai-harness-init --version` meldet sie; der Digest bleibt der eindeutige Beleg gegen die `SHA256SUMS` desselben Releases.

```sh
brew tap pt9912/ai-harness-init https://github.com/pt9912/homebrew-ai-harness-init
brew trust pt9912/ai-harness-init
brew install pt9912/ai-harness-init/ai-harness-init
```

Homebrew lädt Formeln aus einem Fremd-Tap nur nach ausdrücklicher Freigabe: fehlt die Freigabe, bricht der Laden mit *„Refusing to load formula … from untrusted tap"* ab — `brew trust pt9912/ai-harness-init` gibt sie.

Windows trägt dieser Weg nicht — Homebrew kennt keine Windows-Pakete.

---

## 3. Erste Schritte

### Schnelleinstieg

So setzen Sie ein neues Projekt in unter einer Minute auf:

```bash
mkdir mein-projekt && cd mein-projekt
git init
ai-harness-init --lang go --name "Mein Projekt" <zielordner>
```

Anschließend prüfen Sie, dass alles grün ist:

```bash
make gates
```

### Beispielablauf

Während des Aufsetzens sehen Sie eine Abschluss-Zeile wie:

```text
ai-harness-init: Bootstrap (Baseline v6.0.0 vendored + Doc-Gate + Aggregator + Durchsetzung + Template-Baseline) — --lang=go (Skelett verdrahtet).
```

Das bedeutet: Regelwerk und Vorlagen liegen im Repository, die Prüfungen sind verdrahtet, und ein lauffähiges Go-Grundgerüst ist eingebaut. `make gates` läuft danach ohne Fehler durch. (Ohne `--lang` steht statt „Skelett verdrahtet“ die Meldung „sprach-agnostisch (doc-only Gate)“ — siehe [Ohne Sprache aufsetzen](#ohne-sprache-aufsetzen-doc-only).)

### Wichtigstes Bedienkonzept

`ai-harness-init` arbeitet in **getrennten Schritten** und ist **idempotent**. Getrennt heißt: **Init** legt die sprach-agnostische Harness an, das **Sprachmodul** kommt als eigener Schritt dazu (`add-lang`, wiederholbar). `--lang` beim Init ist die **Kurzform**, die beide Schritte in einem Aufruf erledigt — nicht ein einziger, unteilbarer Vorgang.

Idempotent heißt: Sie können denselben Aufruf gefahrlos wiederholen. Bei einem zweiten Lauf wird die **werkzeug-eigene Infrastruktur** (Prüf-Konfiguration, Hooks, Regelwerk) auf den Soll-Stand aufgefrischt, den **dieses Programm mitbringt** — das heilt Abweichungen. Es **hebt Sie nicht auf einen neueren Kurs-Stand**: die Kurs-Version ist im Programm fest eingebaut, ein zweiter Lauf desselben Programms holt denselben Stand. Einen neueren Stand bekommen Sie mit einem **neueren Programm** — oder bewusst über [eine andere Kurs-Version](#eine-andere-kurs-version-verwenden). **Von Ihnen gefüllte Dateien** (Ihre Projekt-Dokumente, `README.md`, Ihr Quellcode) bleiben **unangetastet**. Es gibt **keinen** Kollisions-Abbruch und **kein** `--force` — der Re-Lauf ist der normale, sichere Weg, ein Repository zu **reparieren**.

---

## 4. Aufgaben

Dieser Abschnitt beschreibt die häufigsten Aufgaben Schritt für Schritt.

### Ein neues Projekt aufsetzen

**Voraussetzung:** Ein leeres oder frisch mit `git init` angelegtes Verzeichnis, Docker läuft, Netzwerk ist erreichbar.

**Vorgehen**

1. Führen Sie das Werkzeug mit Zielordner, Sprache und Projektnamen aus — der
   Zielordner als Argument benennt das zu einrichtende Git-Repo, der Aufruf läuft
   darum aus jedem Verzeichnis:

   ```bash
   ai-harness-init --lang go --name "Mein Projekt" <zielordner>
   ```

**Ergebnis:** Das Verzeichnis enthält jetzt Regelwerk, Vorlagen, Prüf-Konfiguration und ein Go-Grundgerüst (siehe [Was wird angelegt](#6-was-wird-angelegt)). Der Platzhalter für den Projektnamen ist durch „Mein Projekt“ ersetzt.

**Hinweise:** Der Aufruf braucht **einmalig** Netzwerk (Regelwerk-Download). `<zielordner>` ist **Pflicht** — ohne ihn bricht der Aufruf mit dem Usage-Text ab, statt still das Verzeichnis einzurichten, in dem er steht; das Ziel muss ein bestehendes Git-Repo sein (`.git` vorhanden), sonst bricht er ebenfalls ab. `--lang` ist **optional** — ohne Sprache setzt das Werkzeug ein rein dokumentgeführtes Repository auf (siehe [Ohne Sprache aufsetzen](#ohne-sprache-aufsetzen-doc-only)). Den Aufruf können Sie gefahrlos wiederholen (siehe [Ein Repository erneut aufsetzen](#ein-repository-erneut-aufsetzen-idempotent)).

### Ohne Projektnamen aufsetzen

**Voraussetzung:** wie oben.

**Vorgehen**

```bash
ai-harness-init --lang go <zielordner>
```

**Ergebnis:** Das Repository wird aufgesetzt, aber der Platzhalter `<Projektname>` bleibt in den Vorlagen stehen. Sie können ihn später von Hand ersetzen. `--name` ist optional.

### Ohne Sprache aufsetzen (doc-only)

**Voraussetzung:** Sie wollen zuerst die Prozess- und Architektur-Dokumente aufsetzen und die Zielsprache **später** entscheiden (empfohlen: „doc führt“ — die Sprache ist eine Architektur-Entscheidung, kein Startargument).

**Vorgehen**

```bash
ai-harness-init --name "Mein Projekt" <zielordner>
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

Standardmäßig entsteht ein **flaches** Grundgerüst: ein Einstiegspunkt, keine Schichten. Es gibt zwei geschichtete Bauformen, und sie sind **keine zwei Strenge-Grade derselben Sache**, sondern eigene Layouts mit eigenen Verzeichnisnamen:

| `--arch` | Bauform | wann |
|---|---|---|
| `flat` (Standard) | ein Einstiegspunkt, keine Schichten | kleine Werkzeuge; Sie wollen die Struktur selbst wählen |
| `hexagonal` | die drei klassischen Schichten: Kern, Ports, Adapter (getrieben/treibend) | der übliche Fall für eine Anwendung mit Fachlogik |
| `hexslice` | dasselbe **plus** vertikale Use-Case-Schnitte (jeder Schnitt mit eigenen Ports) | viele fachlich getrennte Anwendungsfälle, die nebeneinander wachsen sollen |

```bash
ai-harness-init add-lang go apps/api --arch hexagonal
```

**Ergebnis — zusätzlich zum flachen Fall:**

- der Code liegt in Schichten. Bei `hexagonal`: `internal/hexagon/core/…` (Fachlogik **und** Anwendungsfall), `internal/hexagon/port/…` (die Schnittstellen nach außen — bewusst **ohne** eigene Importe), `internal/adapter/driven/…` (was der Kern benutzt: Datenbank, Datei, Fremdsystem), `internal/adapter/driving/…` (was den Kern antreibt: CLI, HTTP), dazu `cmd/<binary>/main.go` als Verdrahtungs-Punkt. Bei `hexslice`: `internal/hexagon/domain/…`, `internal/hexagon/application/<bereich>/<use-case>/…` (mit eigenen `ports/`, gegliedert nach `inbound`/`outbound`), `internal/adapters/{driving,driven}/…`, ebenfalls mit `cmd/<binary>/main.go`;
- **das Architektur-Gate wird mitgeliefert**: `<pfad>/.a-check.yml` (die Schicht-Regeln) und `a-check.mk` (der Prüf-Baustein). `make gates` fährt es ab sofort mit.

Das Architektur-Gate prüft die **Abhängigkeitsrichtung**: Importe zeigen nur nach innen. Ein Verstoß — etwa ein Import aus der Domain in einen Adapter — lässt `make gates` **rot** werden, mit Datei und Zeile:

```text
internal/hexagon/domain/example/greeting.go:8: core-impurity: Kern importiert app/internal/adapters/driven/notify
```

Bei `hexagonal` greifen zwei Regeln, die **unabhängig von den erlaubten Richtungen** gelten und darum auch von keiner zusätzlichen Kante aufgehoben werden. Beide sind an einem echten Lauf gemessen, nicht behauptet:

```text
internal/hexagon/core/greeting.go:9: app-impurity: Application importiert app/internal/adapter/driven/memory
internal/adapter/driving/cli/cli.go:11: lateral-adapter: Adapter importiert anderen Adapter app/internal/adapter/driven/memory
```

Die erste sagt: der **Kern** sieht keinen Adapter — er kennt nur seine Ports. Die zweite: die beiden **Adapter-Seiten sehen einander nie** — was den Kern antreibt, greift nicht selbst auf Datenbank oder Fremdsystem zu. Zusammengesteckt wird ausschließlich in `cmd/<binary>/main.go`: dort entsteht der getriebene Adapter, wird dem Anwendungsfall übergeben und dieser an die treibende Seite.

**Bei `--arch flat` (dem Standard) wird kein Architektur-Gate angelegt** — es gäbe dort keine Schichten zu prüfen, und ein Gate ohne Prüfbereich wäre eine leere Zusage.

**Die treibende Seite wird bei `hexagonal` bewusst mitgeprüft** — strenger, als es verbreitete Vorlagen tun, die sie als reinen Verdrahtungs-Bereich freistellen. Der Grund: ein zu strenger Standard meldet sich beim **ersten** Lauf und kostet Sie eine Zeile; ein zu lascher meldet sich **nie** und lässt einen Bereich still ungeprüft. Wollen Sie die Freistellung, tragen Sie in **Ihrer** `.a-check.yml` `"internal/adapter/driving/**"` unter `composition_root` ein — eine Zeile, in einer Datei, die das Werkzeug nie überschreibt.

**Wichtig für die Pflege:** `.a-check.yml` gehört Ihnen — ein erneutes Aufsetzen überschreibt sie nicht. Bei `hexslice` gilt: legen Sie einen **weiteren** Use-Case-Schnitt an, tragen Sie ihn dort nach (je ein Eintrag unter `app` und, falls er eigene Ports hat, unter `ports_inbound` bzw. `ports_outbound` — je nach Richtung, mit eigenem `direction:`). Diese Rollen-Form ist der veröffentlichte Stand: wer das `v0.2.4` heruntergeladen hat, trägt dort die Rollen-Form mit `direction:`. Vergessen Sie es, fällt der neue Code unter keine Schicht: importiert er eine, meldet das Gate `wrong-direction` — importiert er keine, bleibt er unbemerkt ungeprüft. Bei `hexagonal` wachsen neue Dateien in die bestehenden vier Schichten hinein; nachzutragen ist erst, wenn Sie ein **neues** Schicht-Verzeichnis anlegen.

**Grenzen:** `--arch hexslice` liefert für **beide** Zielsprachen, `--arch hexagonal` derzeit nur der **Go**-Renderer. Eine Sprache, deren Renderer die gewählte Bauform nicht kennt (heute `cpp` mit `hexagonal`), endet mit Exit 2 und nennt die Bauformen, die **diese** Sprache kann — statt still ein Grundgerüst ohne Schichten anzulegen; eine unbekannte Bauform ebenso, mit Nennung der verfügbaren Werte.

### Das aufgesetzte Repository prüfen

**Voraussetzung:** Der Aufsetz-Lauf war erfolgreich; Docker läuft.

**Vorgehen**

```bash
make gates
```

**Ergebnis:** Alle Prüfungen laufen durch (Exit-Code 0). Dazu gehören die Dokumentations-Prüfung und die Go-Prüfungen (Kompilieren, Test, Linter). Ein grüner Lauf bestätigt: Das Repository ist aufsetzbereit und korrekt verdrahtet.

**Hinweise:** `make gates` nutzt Docker. Läuft Docker nicht, schlägt die Prüfung mit einer Docker-Fehlermeldung fehl — kein Fehler des Repositorys.

**Ein bereits aufgesetztes Repository geklont — kein eigener `ai-harness-init`-Lauf.** Haben Sie ein Repository geklont, das jemand anderes (oder eine CI) bereits aufgesetzt hat, brauchen Sie keinen eigenen Lauf: `make gates` funktioniert unverändert, denn die Gates prüfen nur Docker und den versionierten Inhalt.

**Was dabei fehlt:** Der **Träger** — die `ai-harness-init`-Programmdatei selbst, die das Repository für zwei der vier [Betriebs-Operationen](#betriebs-operationen) (`archive-welle`, `span-report`) braucht — liegt in einem **gitignorierten** Zustands-Bereich (`.harness/state/bin/`) und reist deshalb **nicht** mit einem Klon. `make gates` bleibt davon unberührt, ebenso `make span-clean`, das den Träger gar nicht anfasst. `make archive-welle`/`make span-report` melden nach einem frischen Klon: *„der Traeger liegt nicht … dieses Repo … nicht"* — kein Fehler, kein rotes Gate, nur eine Aussage über den fehlenden Träger.

**Wie der Träger zurückkommt:** `make traeger-fetch` holt ihn aus dem gepinnten Release nach — **einmalig** Netzwerk für diesen Aufruf, danach funktionieren `archive-welle` und `span-report` ebenfalls.

### Ein Repository erneut aufsetzen (idempotent)

**Voraussetzung:** Sie wollen ein bereits aufgesetztes Verzeichnis reparieren — etwa nach einem abgebrochenen Lauf oder nachdem eine werkzeug-eigene Datei versehentlich verändert wurde. (Auf einen **neueren Kurs-Stand** hebt Sie dieser Lauf **nicht**; dafür siehe [Eine andere Kurs-Version verwenden](#eine-andere-kurs-version-verwenden).)

**Vorgehen** — einfach denselben Aufruf wiederholen:

```bash
ai-harness-init --lang go --name "Mein Projekt" <zielordner>
```

**Ergebnis:** Der Lauf ist **idempotent** (Exit-Code 0). Die werkzeug-eigene Infrastruktur (Prüf-Konfiguration, Hooks, die zentrale `Makefile`, Regelwerk) wird auf den Soll-Stand **aufgefrischt**, den dieses Programm mitbringt — das heilt Abweichungen, holt aber **denselben** Kurs-Stand wie beim ersten Lauf. **Von Ihnen gefüllte Dateien** — die Dokumente unter `spec/`, `README.md`, `AGENTS.md`, Ihr Quellcode im Grundgerüst (`go.mod`, `cmd/app/main.go` …) — bleiben **unangetastet**.

**Hinweise:** Es gibt **kein** `--force` und **keinen** Kollisions-Abbruch. Wollen Sie eine von Ihnen bearbeitete werkzeug-eigene Datei bewusst auf den Ausgangsstand zurücksetzen, löschen Sie sie vor dem Re-Lauf — dann wird sie neu geschrieben. **Nicht jede werkzeug-eigene Datei wird aufgefrischt:** eine vorhandene `.d-check.yml` und drei der fünf `.gitattributes` bleiben unberührt (siehe [Zeilenenden und Kennungs-Form der Prüf-Konfiguration](#zeilenenden-und-kennungs-form-der-prüf-konfiguration)).

### Eine andere Kurs-Version verwenden

**Voraussetzung:** Sie möchten das Regelwerk von einem anderen als dem voreingestellten Kurs-Stand beziehen.

**Vorgehen**

```bash
COURSE_TAG=v3.5.2 ai-harness-init --lang go --name "Mein Projekt" <zielordner>
```

**Ergebnis:** Das Regelwerk wird vom angegebenen Kurs-Stand geholt. Ohne die Variable wird der im Werkzeug festgelegte, geprüfte Stand verwendet.

**Hinweise:** Voreingestellte Werte sind bewusst festgelegt (reproduzierbar). Ändern Sie sie nur, wenn Sie einen bestimmten Stand brauchen. Siehe [Konfiguration](#5-konfiguration).

### Die Go-Version des Grundgerüsts festlegen

**Voraussetzung:** Das erzeugte Go-Grundgerüst soll eine bestimmte Go-Version verwenden.

**Vorgehen**

```bash
SKEL_GO_VERSION=1.26.4 ai-harness-init --lang go --name "Mein Projekt" <zielordner>
```

**Ergebnis:** Das erzeugte Grundgerüst (`Dockerfile`, `go.mod`) verwendet die angegebene Go-Version. Ohne die Variable gilt die festgelegte Standard-Version.

### Betriebs-Operationen

**Voraussetzung:** Ein aufgesetztes Repository. Docker braucht nur `traeger-fetch` — der Transport läuft im gepinnten Bild. Von den drei übrigen rufen `archive-welle` und `span-report` den bereits abgelegten **Träger** (die `ai-harness-init`-Programmdatei im gitignorierten Zustands-Bereich `.harness/state/bin/`) direkt auf; `span-clean` braucht weder den Träger noch Docker, es räumt nur den lokalen Erfassungs-Bestand weg.

Alle vier sind **keine Gates**: `make gates` fährt keine von ihnen mit. `archive-welle` und `span-report` melden fehlenden Träger, statt rot zu färben (siehe [Ein bereits aufgesetztes Repository geklont](#das-aufgesetzte-repository-prüfen)); `traeger-fetch` legt ihn bei Bedarf erst ab; `span-clean` prüft den Träger gar nicht — sein Rezept löscht bedingungslos.

| Kommando | Tut was |
|---|---|
| `make traeger-fetch` | Holt den Träger aus dem gepinnten Release nach und legt ihn im Zustands-Bereich ab. Braucht **einmalig** Netzwerk für diesen Aufruf; danach nicht mehr. `archive-welle` und `span-report` setzen ihn voraus. |
| `make archive-welle WELLE=<welle-id>` | Archiviert die Zeitdokumente einer geschlossenen Welle (Slice-Dateien, Welle-Plan, Review-Reports) und committet den Vorgang im versionierten Baum. Fehlt der Träger, schreibt das Kommando nichts und sagt das. |
| `make span-report` | Zeigt eine Token-Bilanz je Rolle aus dem lokalen Erfassungs-Bestand — ein reiner, netzloser Bericht. Fehlt der Träger, meldet das Kommando das als Aussage über den Leser, nicht über den Bestand. |
| `make span-clean` | Entfernt den lokalen Erfassungs-Bestand. Läuft nur auf **ausdrücklichen** Aufruf; kein Automatismus räumt ihn sonst auf. |

**Ergebnis:** Ein frischer Klon hat den Träger nicht (er ist gitignoriert); `make traeger-fetch` legt ihn ab, danach funktionieren `archive-welle` und `span-report` ohne weiteres Netzwerk. `span-clean` funktioniert unabhängig davon, mit oder ohne Träger.

---

## 5. Konfiguration

### Aufruf-Optionen (Aufsetzen)

| Option | Pflicht | Bedeutung |
|---|---|---|
| `--lang <sprache>` | nein | Zielsprache des Grundgerüsts (Kurzform für „aufsetzen + `add-lang(<sprache>, .)`“). Ohne sie: dokument-only. Derzeit unterstützt: `go`, `cpp` (C++ per CMake + clang-tidy). |
| `--arch <arch>` | nein | Bauform des Grundgerüsts: `flat` (Standard), `hexagonal` (drei Schichten) oder `hexslice` (Schichten plus Use-Case-Schnitte); die beiden geschichteten bringen das Architektur-Gate mit. Wirkt nur zusammen mit `--lang`. Siehe [Ein geschichtetes Grundgerüst wählen](#ein-geschichtetes-grundgerüst-wählen---arch). |
| `--name <name>` | nein | Projektname; ersetzt den Platzhalter `<Projektname>` in den Vorlagen. |
| `-h`, `--help` | nein | Hilfe anzeigen und beenden. |

Ein `--force` gibt es **nicht** — der Re-Lauf ist idempotent (siehe [Ein Repository erneut aufsetzen](#ein-repository-erneut-aufsetzen-idempotent)).

### Subkommando `add-lang`

```bash
ai-harness-init add-lang <sprache> <pfad>
```

Fügt einem bereits aufgesetzten Repository ein Sprachmodul hinzu — **wiederholbar** (Mono-Repo), auch mit gemischten Sprachen. Beide Positions-Argumente sind Pflicht: `<sprache>`, `<pfad>` (Zielort im Repository; `.` = Wurzel). Optional folgt **nach** ihnen `--arch <arch>` (`flat`, `hexagonal` oder `hexslice`); die Bauform ist je Modul frei wählbar, ein Mono-Repo darf sie mischen. Siehe [Ein Sprachmodul hinzufügen](#ein-sprachmodul-hinzufügen-add-lang) und [Ein geschichtetes Grundgerüst wählen](#ein-geschichtetes-grundgerüst-wählen---arch).

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
| `A_CHECK_IMAGE` | Abweichende Referenz für das Architektur-Prüf-Image (nur bei einer geschichteten Bauform genutzt). |
| `A_CHECK_DIGEST` | Abweichende Prüfsumme (Digest) des Architektur-Prüf-Images; sticht die Referenz. |

Beispiel mit mehreren Variablen:

```bash
COURSE_TAG=v3.5.2 SKEL_GO_VERSION=1.26.4 ai-harness-init --lang go --name "Mein Projekt" <zielordner>
```

---

## 6. Was wird angelegt

Der Bootstrap läuft in **Phasen**: Ein **Aufsetzen ohne Sprache** legt die dokument-geführte Basis an; ein **Sprachmodul** kommt danach per `--lang <sprache>` (Kurzform beim Aufsetzen) oder jederzeit per `add-lang <sprache> <pfad>` dazu — wiederholbar zu einem Mono-Repo. Entsprechend zeigen wir beide Fälle.

### Phase 1 — Aufsetzen ohne Sprache (dokument-only)

`ai-harness-init --name "Mein Projekt" <zielordner>` (ohne `--lang`) legt die sprach-unabhängige Basis an (leere Prozess-Ordner werden mit einer `.gitkeep`-Datei gehalten, damit `git` sie behält):

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
├── docs/plan/                Planung: Architektur-Entscheidungen, Slices, Roadmap, Beobachtungs-Register
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

Mit einer geschichteten Bauform sieht der Code-Teil anders aus (die Bau-Dateien bleiben gleich): statt eines einzelnen Einstiegspunkts entstehen Schichten — bei `hexslice` `internal/hexagon/{domain,application}` und `internal/adapters/{driving,driven}`, bei `hexagonal` `internal/hexagon/{core,port}` und `internal/adapter/{driven,driving}` —, dazu `cmd/<binary>/main.go` und **plus** das Architektur-Gate `<pfad>/.a-check.yml` und `a-check.mk`. Bei `flat` (dem Standard) entsteht keines von beidem. Siehe [Ein geschichtetes Grundgerüst wählen](#ein-geschichtetes-grundgerüst-wählen---arch).

### Zeilenenden und Kennungs-Form der Prüf-Konfiguration

**Zeilenenden.** Das Aufsetzen legt in fünf Verzeichnissen je eine `.gitattributes` mit der einen Zeile `* text=auto eol=lf` an — dort, wo ein Interpreter oder die Byte-Prüfung des Regelwerks die Dateien liest und ein CR am Zeilenende sie bricht. Die Zeile legt LF fest, unabhängig von `core.autocrlf` und von einer `.gitattributes` in der Wurzel Ihres Repositorys; ein Klon mit `core.autocrlf=true` trägt in diesen Verzeichnissen kein CR. Die Wurzel bekommt keine `.gitattributes`: Ihre Dateien dort schreibt git nach Ihrer eigenen Einstellung. Die fünf Dateien listet, im aufgesetzten Repository ausgeführt:

```bash
find . -name .gitattributes -not -path './.harness/baseline/*' | wc -l    # 5
```

Bei einem erneuten Aufsetzen unterscheiden sich die fünf in einem Punkt:

| Verzeichnis | Beim erneuten Aufsetzen |
|---|---|
| `.harness/`, `tools/harness/` | wird jedes Mal neu geschrieben — eine von Hand geänderte Datei ist danach wieder die mitgelieferte |
| `harness/mk/`, `.claude/hooks/`, `.githooks/` | eine vorhandene Datei bleibt unberührt; der Lauf nennt Verzeichnis und Folge: „Trägt sie die Zeile `* text=auto eol=lf` nicht, tragen die Dateien in `<verzeichnis>/` im Klon mit core.autocrlf=true CRLF." <!-- d-check:ignore (die Pfade entstehen erst im aufgesetzten Repository) --> |

**Kennungs-Form der `.d-check.yml`.** Die mitgelieferte Prüf-Konfiguration der Dokumentation kennt Slices und Welle-Pläne als **Namen**: die Klassen `slice` und `welle` tragen die Präfix-Token `slice-` und `welle-`, und die Regel `spec-straten → welle` verbietet einer Spec-Datei, eine Welle-Datei zu nennen — ebenso wie eine Architektur-Entscheidung, einen Slice, den Adaptions-Block oder etwas außerhalb der Spec. Das Kennungs-Muster der Architektur-Entscheidungen nimmt ein **optionales Bereichs-Segment** (`ADR-<Nummer>` ebenso wie `ADR-<Bereich>-<Nummer>`, die Nummer vierstellig) und verlangt für beide einen Link; die Klasse `adr` deckt neben `docs/plan/adr/[0-9]*.md` auch `docs/plan/adr/[A-Z]*-[0-9]*.md`. Ein frisch aufgesetztes Repository meldet mit `make docs-check` `0 Befund(e)`; eine blanke Kennung mit Bereichs-Segment im Fließtext färbt es rot (`id-unlinked`), ebenso ein Link aus `spec/architecture.md` auf eine Datei `welle-<name>.md` (`matrix-forbidden`).

Die `.d-check.yml` gehört Ihnen, sobald sie da ist: eine vorhandene Datei bleibt beim erneuten Aufsetzen **unberührt, ohne Meldung** — auch ein Repository, das mit einer früheren Fassung des Programms aufgesetzt wurde, behält seine. Diese Positionen tragen Sie dann von Hand nach: die Präfix-Token `slice-` und `welle-`, die Regel `{from: spec-straten, to: welle, allow: false}`, das Muster `ADR-([A-Z]+-)?\d{4}` im Block `ids` und den Glob `docs/plan/adr/[A-Z]*-[0-9]*.md` in der Klasse `adr`.

Die Dateien mit der Endung `.template.md` unter `.harness/baseline/` sind **Vorlagen**: Sie kopieren sie bei Bedarf und füllen sie aus (z. B. für eine neue Architektur-Entscheidung). Die Prozess-Regeln erklären, wann welche Vorlage zum Einsatz kommt.

---

## 7. Fehlerbehebung

Alle Fehler von `ai-harness-init` beginnen auf der Fehlerausgabe mit `Fehler:` und liefern einen von Null verschiedenen Exit-Code (siehe [Anhang](#10-anhang)).

### Fehler: `unbekannte Sprache "…"; verfuegbar: cpp, go`

**Ursache:** Sie haben eine Sprache angegeben, für die es (noch) kein Grundgerüst gibt.

**Lösung:** Verwenden Sie eine der aufgelisteten Sprachen. Derzeit sind das `go` und `cpp`:

```bash
ai-harness-init --lang cpp <zielordner>
```

### Fehler: `kein Aggregator (Makefile) — zuerst ai-harness-init (Init) im Repo laufen lassen`

**Ursache:** Sie haben `add-lang` in einem Verzeichnis aufgerufen, das noch **nicht** aufgesetzt ist (es fehlt die `Makefile`, die das Sprachmodul einbindet).

**Lösung:** Setzen Sie das Repository zuerst auf (mit oder ohne Sprache), dann `add-lang`:

```bash
ai-harness-init --name "Mein Projekt" <zielordner>
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
Ja — der Aufruf ist **idempotent** (Exit-Code 0). Ein zweiter Lauf frischt die werkzeug-eigene Infrastruktur auf und lässt Ihre eigenen Dateien unangetastet. Genau so **reparieren** Sie ein Repository. Auf einen neueren Kurs-Stand hebt Sie der Re-Lauf **nicht** — die Kurs-Version steckt im Programm; dafür brauchen Sie ein neueres Programm oder [eine andere Kurs-Version](#eine-andere-kurs-version-verwenden).

**Wie füge ich eine zweite Sprache oder ein weiteres Modul hinzu?**
Mit `ai-harness-init add-lang <sprache> <pfad>`. Der Befehl ist wiederholbar; mehrere Aufrufe mit verschiedenen Pfaden ergeben ein Mono-Repo. Siehe [Ein Sprachmodul hinzufügen](#ein-sprachmodul-hinzufügen-add-lang).

**Gibt es ein fertiges Download-Binary?**
Ja — für sechs Plattformen (Linux, macOS, Windows × Intel/AMD und ARM). Das ist der empfohlene Weg, siehe [Installation](#2-installation-und-zugriff). Den Bau aus dem Quellcode brauchen Sie nur für einen Stand ohne Versions-Kennzeichnung.

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

* Im Quellcode-Repository liegt **kein** eingecheckt vorliegendes Binary und kein `run`-Ziel. Fertige Programme gibt es **an den Releases**; wer aus dem Quellcode baut, arbeitet gegen den Repo-Stand und hat dann keine Versions-Kennzeichnung.
* Der erste Lauf benötigt Netzwerk; danach ist das Repository netzunabhängig.
* `ai-harness-init` und die Prüfungen im Zielrepository benötigen Docker.
* Voreingestellte Versionen (Kurs-Stand, Go-Version, Prüf-Image) sind festgelegt und reproduzierbar; Abweichungen nur über die Umgebungsvariablen aus [Konfiguration](#5-konfiguration).
* **Sicherheit:** Das Regelwerk wird beim Download gegen eine feste Prüfsumme verifiziert (`BASELINE_SHA256`); das aufgesetzte Repository fängt riskante Befehle über den Command-Guard ab und lässt die Prüfungen nur in Docker laufen.

### Support und Kontakt

* Quellcode und Fehlermeldungen: das Projekt-Repository `ai-harness-init` (pt9912).
* Lizenz: MIT.

---
