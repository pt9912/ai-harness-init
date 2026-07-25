# Slice slice-048: Release-Artefakte (Plattform-Matrix)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (die Anforderung steht seit Langem im Lastenheft; sie braucht keinen
Wellen-Trigger, sondern Abdeckung).

**Bezug:** [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0003](../../adr/0003-go-native-binaries.md), [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-25.

---

## 1. Ziel

Der Build erzeugt **native Binaries für die volle Plattform-Matrix** (linux · macos · windows ×
amd64 · arm64), cross-kompiliert im gepinnten Image, und ein **tag-getriebener** Release-Workflow
lädt sie ans GitHub-Release. Damit bekommt [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
— seit Langem vertraglich zugesagt — zum ersten Mal Abdeckung.

## 2. Definition of Done

- [x] **Schritt 0 — CR am Lastenheft (vor Code):** die Messmethode von [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
      verlangt „Plattform-Smoke in der CI-Matrix". Das ist so **nicht erfüllbar**: `make full-smoke`
      braucht einen Linux-Docker-Daemon, den die macOS-Runner nicht haben und die Windows-Runner nur
      für Windows-Container. Die Messmethode wird auf real Messbares präzisiert — **Start-Smoke** je
      Plattform (Binary läuft, meldet seine Usage, Exit 0) plus **Voll-Smoke auf Linux** — und die
      Grenze wird im Lastenheft **benannt** statt weggelassen. Ohne diesen CR wäre der Rest ein Gate,
      das eine Plattform-Zusage nur behauptet ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [x] **Cross-Compile:** die `build`-Stage im `Dockerfile` nimmt die Zielplattform als Build-Args;
      ohne Angabe bleibt das heutige Verhalten **byte-identisch** (`make artifact` und beide Smokes
      dürfen sich nicht bewegen).
- [x] **Matrix-Target:** ein `make`-Target erzeugt alle sechs Binaries nach `DEST` mit
      plattform-tragenden Namen; `DEST` bleibt Pflicht (Exit 2 ohne). Docker-only, kein
      Host-Toolchain-Aufruf ([ADR-0003](../../adr/0003-go-native-binaries.md)).
- [x] **Reproduzierbarkeit** ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)):
      zwei Läufe derselben Version liefern je Plattform byte-identische Binaries — gemessen, nicht
      behauptet.
- [x] **Release-Workflow:** eigene `.github/workflows/release.yml`, **tag-getrieben**, definiert
      **keinen Check in der YAML** ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
      Setzung 1, Nachtrag 2026-07-25): der Bau steckt in `make release-artifacts`, der Start-Smoke in
      `harness/tools/start-smoke.sh` — beides versioniert im Repo, der Step ruft nur. Lädt die
      Artefakte ans Release.
      **Nicht** in `ci.yml`: Setzung 2 trennt nach Sensor-Klasse, ein Release-Job liefe sonst bei
      jedem Push mit.
- [x] **Plattform-Smoke nach dem CR:** Start-Smoke je Plattform, Voll-Smoke weiter nur auf Linux.
      `ci-lint` deckt den neuen Workflow **syntaktisch** — sein **Verhalten** ist per
      `workflow_dispatch` real gemessen: Lauf `30166346539` grün auf **allen sechs** Runnern
      (`ubuntu-24.04`, `ubuntu-24.04-arm`, `macos-26-intel`, `macos-26`, `windows-2025`,
      `windows-11-arm`), `publish` korrekt übersprungen. Damit sind die Runner-Labels **gemessen**
      statt der Runner-Images-Doku entnommen.
      **Der Lauf davor (`30166231831`) war rot — und das ist der Beleg, dass er nötig war:** alle
      sechs Jobs scheiterten identisch an `dist/<binary> existiert nicht`, weil `actions/checkout`
      (Default `clean: true`) das zuvor heruntergeladene Artefakt löschte. Ein Reihenfolge-Fehler,
      den **kein** lokales Gate sehen kann.
      **Verortung entschieden (2026-07-25): im `release.yml`, nicht in `ci.yml` und nicht in einer
      vierten Datei.** Vier Gründe: (a) die Messmethode bindet den Nachweis an die **Release-Artefakte**
      — dort entstehen sie, dort werden sie geprüft, ohne zweiten Build oder Weiterreichen zwischen
      Workflows; (b) [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
      Setzung 2 trennt nach **Sensor-Klasse**, nicht nach Runner-Typ — tag-getrieben ist die dritte
      Klasse, keine vierte; (c) `ci.yml` bleibt homogen (heute vier Jobs, alle `ubuntu-24.04`, alle
      Docker); (d) macOS-Runner pro Push für einen Start-Smoke wären viel Laufzeit für wenig Aussage.
      **Preis, benannt:** das Feedback kommt erst beim Tag. Gegenmaßnahme wie bei
      `upstream-drift.yml`: `workflow_dispatch`, damit der Nachweis vor dem Tag manuell anstoßbar ist.
- [x] `make gates` grün · `make mutate` grün mit rot gesehener Mutation je neuem Wächter
      (Cross-Compile-Verdrahtung · `DEST`-Pflicht · Matrix-Vollständigkeit).
- [x] `make full-smoke` unverändert grün (der Default-Pfad darf sich nicht bewegen).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

<!--
Welche Änderungen sind geplant? Datei- oder Komponenten-Ebene reicht.
Der Implementation-Agent erweitert diese Liste in seinem ersten Lauf.
-->

Ist-Stand **gemessen** (2026-07-25, vor dem Schnitt): die `build`-Stage kennt keine
Zielplattform-Args; `make artifact DEST=<dir>` kopiert **ein** Binary aus dem Build-Image; unter
`.github/workflows/` liegen nur `ci.yml` und `upstream-drift.yml`, also kein Release-Workflow; die
Matrix steht vollständig in `spec/lastenheft.md`. Die Zusage ist damit älter als jede Abdeckung.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `spec/lastenheft.md` | update (CR) | Messmethode [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) auf real Messbares präzisieren, Grenze benennen — **vor** dem Code |
| `Dockerfile` | update | `build`-Stage um Zielplattform-Build-Args; Default-Verhalten byte-identisch |
| `Makefile` | update | Matrix-Target über die sechs Kombinationen; `artifact` bleibt unverändert |
| `.github/workflows/release.yml` | neu | tag-getrieben (+ `workflow_dispatch`), **kein Check in der YAML** (Bau via `make release-artifacts`, Start-Smoke via `harness/tools/start-smoke.sh`), Upload ans Release — **und** die Start-Smoke-Matrix (macos/windows/linux) |
| `test/` + `test/mutations/` | neu | Wächter je neuer Zusage, jeder mit rot färbender Mutation |
| `harness/tools/start-smoke.sh` | neu | der Plattform-Nachweis als versioniertes, `shell-lint`-gedecktes Skript (ungeplant — Folge des Review-Befundes zur [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)-Setzung 1) |

## 4. Trigger

<!--
Wann beginnt dieser Slice? (`next` → `in-progress`: Implementer beginnt.)
Beispiele: "Wenn Welle X done." / "Wenn Carveout CO-NN aufgelöst."

Auch die zwei Rückführungen vorab benennen — unter welcher Bedingung
geht dieser Slice zurück?
- `in-progress` → `next`: zu groß, zurück zur Zerlegung.
- `in-progress` → `open`: blockiert (Carveout? siehe Modul 7).
(kanonische Definition: [`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine))
-->

- **Beginn (`open` → `in-progress`):** slice-047 **done**, WIP-Limit frei — erfüllt.
- **`in-progress` → `next` (zu groß):** der wahrscheinlichste Rücksprung. Kandidaten-Schnitt dann:
  (a) Cross-Compile + Matrix-Target, (b) Release-Workflow + Upload, (c) Plattform-Smoke-Matrix.
  Der CR bleibt in jedem Fall Schritt 0 des ersten Teils.
- **`in-progress` → `open` (blockiert):** falls der CR ergibt, dass die Matrix ohne eigene
  Plattform-Runner nicht ehrlich messbar ist — dann Carveout (Modul 7) statt einer Behauptung.

## 5. Closure-Trigger

DoD vollständig, `make gates` + `make mutate` + `make full-smoke` grün mit rot gesehenen Mutationen,
die sechs Artefakte real erzeugt und ihre Reproduzierbarkeit gemessen, Review konform + Verifier
bestätigt die DoD, Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Die Messmethode ist die eigentliche Schwierigkeit, nicht der Build.** Cross-Compile ist in
  dieser Toolchain billig; ein *ehrlicher* Plattform-Nachweis ist es nicht. Ein Start-Smoke belegt,
  dass das Binary auf der Plattform **läuft** — nicht, dass der Bootstrap dort funktioniert. Diese
  Grenze gehört benannt, sonst entsteht genau das halluzinierte Gate, das
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) verbietet.
- **Windows-Runner haben Docker, aber für Windows-Container.** „Docker vorhanden" heißt dort nicht
  „`make full-smoke` läuft". Vor jeder Zusage messen, nicht annehmen.
- **Byte-Identität des Default-Pfads:** `artifact`, `smoke` und `full-smoke` hängen am heutigen
  Build-Ziel. Build-Args mit Default dürfen es nicht verschieben — die slice-044-Disziplin
  (additive Erweiterung schützt die vorhandenen Sensoren).
- **Der Release-Upload ist nicht lokal rot-sehbar** — aber **probeweise fahrbar**: ein
  SemVer-Vorab-Tag (`v0.1.0-RC`) durchlaeuft die ganze Kette inklusive Upload und wird als
  `--prerelease` markiert, also klar erkennbar und hinterher loeschbar. `workflow_dispatch`
  deckt die Stufe davor (bauen + Start-Smoke ohne jeden Upload). Damit bleibt nur der
  Unterschied zwischen Vorab- und Endversion ungeprobt. Es bleibt dieselbe Grenze, die
  [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) für die CI
  benennt: `ci-lint` belegt die Syntax des Workflows, nicht sein Verhalten. Der erste echte Tag ist
  die Instanz, die es zeigt; das ist ehrlich zu benennen statt „getestet" zu behaupten.
- **Signatur/Notarisierung** (macOS-Gatekeeper, Windows-SmartScreen) ist **out-of-scope**: das
  Lastenheft verlangt sie nicht, und ein halber Signaturpfad wäre schlechter als keiner.

## 7. Closure-Notiz (nach `done/`)
**Geliefert.** [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) hatte seit Lastenheft-Version 0.2.0 **null Abdeckung**: die build-Stage
kannte keine Zielplattform, `make artifact` zog ein Binary, ein Release-Workflow existierte nicht.
Jetzt erzeugt `make release-artifacts DEST=<dir>` alle sechs nativen Binaries (Formate per `file`
und per `od` auf Ziel-OS **und** Ziel-Architektur geprüft), und `release.yml` baut, smoked auf sechs
Runnern und hängt sie ans Release. Der Default-Pfad blieb **byte-identisch** — gegen den Stand vor
der Änderung per `git stash` gemessen.

**Anders als geplant — vier Dinge:**

1. **Schritt 0 wurde größer als gedacht.** Die Messmethode von [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) war nicht erfüllbar; der
   CR (Lastenheft **0.13.0**) präzisiert sie auf Start-Smoke je Plattform plus Voll-Smoke auf Linux
   und **benennt die Grenze**, statt sie wegzulassen.
2. **`harness/tools/start-smoke.sh` war ungeplant** — Folge eines Review-Befundes: der Start-Smoke
   lag zuerst als bash-Block in der YAML und verletzte damit
   [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) Setzung 1.
3. **Der [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)-Nachtrag musste zweimal geschrieben werden.** Die erste Fassung band die Ausnahme
   an den **Runner**; die zweckwahrende Eigenschaft stand nur in der Begründung. Jetzt ist die Norm
   die Eigenschaft.
4. **Drei reale Release-Läufe statt null.** Der erste war rot.

**Steering-Loop-Einträge.**

- **Ein Workflow ist erst geprüft, wenn er gelaufen ist.** `ci-lint` belegt die **Syntax**, nicht das
  **Verhalten** — und `runs-on: ${{ matrix.runner }}` kann es nicht einmal syntaktisch prüfen. Der
  erste Dispatch-Lauf scheiterte auf **allen sechs** Runnern identisch: `actions/checkout` räumt den
  Workspace per Default auf (`clean: true`) und löschte das zuvor heruntergeladene Artefakt. Kein
  Gate dieses Repos kann das sehen. **Regel: zu jedem neuen Workflow gehört ein realer Lauf VOR der
  Closure, nicht danach.**
- **Grün heißt nicht befundfrei.** Der `artifacts`-Job war „success" — und trug sieben
  Deprecation-Warnungen (`Node.js 20`), die ich überlas, weil ich auf das Ergebnis schaute statt in
  den Lauf. Gefunden hat sie der Nutzer. **Regel: einen grünen Lauf auf Warnungen lesen, nicht nur
  auf sein Ergebnis.** Nach dem Bump: 7 → 0, gemessen.
- **Ein Lookup ist nur so gut wie seine Frage.** Ich hatte die Action-SHAs *nachgeschlagen* statt
  geraten — aber nach dem Tag `v4` gefragt und exakt das bekommen: den Stand, auf den der Major-Tag
  zeigt. Aktuell waren v7.0.1 und v8.0.1. **Regel: nach `releases/latest` fragen; „ich habe
  nachgeschlagen" ist keine Aussage über Aktualität.**
- **Eine Regel für den Anlass statt für den Zweck zu formulieren, bindet sie an den falschen
  Gegenstand.** Mein erster [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)-Nachtrag erlaubte die Ausnahme „auf Runnern ohne `make`" — damit
  wäre ein Inline-Prüfblock in der YAML gedeckt gewesen, sobald er auf Windows läuft, und zugleich
  war der Linux-Zweig des realen Workflows nicht gedeckt. Der Zweck der Setzung ist **eine Quelle je
  Check**; das ist jetzt die Norm, die `make`-Verfügbarkeit nur noch der Grund.

**Was gut lief.** Die Reihenfolge Doc-führt (CR vor Code) hat sich ausgezahlt: ohne ihn wäre ein
Gate entstanden, das eine Plattform-Zusage nur behauptet. Und die Disziplin, **jede Mutation vor der
Fertig-Meldung zu bauen**, hat zwei eigene Fehler gefangen, bevor eine Rolle sie sehen musste — den
`! cmd`-vor-`set -e`-Fallstrick und einen Test, der aus der falschen Ursache grün war.

**Benannte Restrisiken (kein Folge-Slice):**

- ~~Der **`publish`-Pfad** ist strukturell fertig, aber zum Zeitpunkt dieser Closure **nie
  gelaufen**~~ — **eingelöst, siehe Nachtrag unten.**
- Die Runner-Labels sind gemessen (Lauf `30168310098` grün auf allen sechs), aber ein
  **Label-Wegfall** würde erst beim nächsten Lauf auffallen — `ci-lint` kann `runs-on`-Ausdrücke
  nicht prüfen.
- Der `publish`-Inline-Block in der YAML ist ~20 Zeilen ungelintete Logik — dieselbe „eine
  Quelle"-Achse wie beim Start-Smoke, hier bewusst nicht mitgezogen (er ruft nur `gh`).
- **Signatur/Notarisierung** (macOS-Gatekeeper, Windows-SmartScreen) bleibt out-of-scope.
- `make` wurde nur für `windows-2025` und `macos-26` als fehlend belegt, nicht für alle vier
  `make`-losen Labels — für die neue Norm ist das unerheblich, sie hängt nicht mehr am Runner.

**Folge-Slices:** keine neuen. Die **Action-Pins** gehören in denselben Vollständigkeits-Wächter wie
die Freshness-Achsen (Roadmap-Kandidat „Inventar gegen Abdeckung") — dieser Slice liefert dafür den
dritten Bedarfsnachweis.


## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): additive Erweiterung der
Bau-Kette (eine `Dockerfile`-Stage bekommt Build-Args, ein neues `make`-Target) und ein neuer
Workflow neben zwei bestehenden. Der Default-Pfad bleibt byte-identisch, es entsteht keine neue
Sub-Area und kein Diskrepanz-Risiko.

Einzige Ausnahme mit anderem Charakter ist der **CR am Lastenheft**: dort gilt Doc-führt — die
Präzisierung der Messmethode geht dem Code voraus, nicht umgekehrt.

---

## Nachtrag nach der Closure (2026-07-25)

Der oben als Restrisiko geführte **`publish`-Pfad ist eingelöst.** Er wurde nach der Closure per
Vorab-Tag `v0.1.0-RC` real gefahren (Lauf `30169789629`, grün über alle acht Jobs). Belegt sind
damit genau die vier Dinge, für die es keinen lokalen Sensor gibt:

- `gh` findet das Repo **ohne Checkout** (der `GH_REPO`-Fix aus Review-Befund F-1),
- `gh release view` → nicht vorhanden → **`create`** statt `upload` (der Defekt, der beim Nachdenken
  über einen Vorab-Tag auffiel),
- die Vorabversions-Erkennung greift: das Release trug `isPrerelease: true`,
- die `contents: write`-Permissions genügen; **sechs Assets** hingen am Release (5,9–6,6 MB).

Das Prerelease samt Tag wurde nach der Probe wieder entfernt — Stand danach verifiziert: kein
Release, kein Remote-Tag, kein lokaler Tag.

**Warum dieser Nachtrag und keine Korrektur oben:** die Notiz beschreibt den Stand *zur Closure*,
und der war korrekt. Sie würde aber eine überholte Aussage führen, wenn der Beleg nur im
Sitzungsverlauf stünde. Ein sichtbarer Nachtrag hält beides — den damaligen Stand und die
Einlösung.

**Der Steering-Eintrag „ein Workflow ist erst geprüft, wenn er gelaufen ist" bekommt damit seinen
vierten Beleg** — und diesmal einen positiven: der Lauf hat nichts gefunden, weil die drei vorherigen
Läufe alles gefunden hatten, was zu finden war.
