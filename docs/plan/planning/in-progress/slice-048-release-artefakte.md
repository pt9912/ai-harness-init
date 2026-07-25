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

- [ ] **Schritt 0 — CR am Lastenheft (vor Code):** die Messmethode von [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
      verlangt „Plattform-Smoke in der CI-Matrix". Das ist so **nicht erfüllbar**: `make full-smoke`
      braucht einen Linux-Docker-Daemon, den die macOS-Runner nicht haben und die Windows-Runner nur
      für Windows-Container. Die Messmethode wird auf real Messbares präzisiert — **Start-Smoke** je
      Plattform (Binary läuft, meldet seine Usage, Exit 0) plus **Voll-Smoke auf Linux** — und die
      Grenze wird im Lastenheft **benannt** statt weggelassen. Ohne diesen CR wäre der Rest ein Gate,
      das eine Plattform-Zusage nur behauptet ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [ ] **Cross-Compile:** die `build`-Stage im `Dockerfile` nimmt die Zielplattform als Build-Args;
      ohne Angabe bleibt das heutige Verhalten **byte-identisch** (`make artifact` und beide Smokes
      dürfen sich nicht bewegen).
- [ ] **Matrix-Target:** ein `make`-Target erzeugt alle sechs Binaries nach `DEST` mit
      plattform-tragenden Namen; `DEST` bleibt Pflicht (Exit 2 ohne). Docker-only, kein
      Host-Toolchain-Aufruf ([ADR-0003](../../adr/0003-go-native-binaries.md)).
- [ ] **Reproduzierbarkeit** ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)):
      zwei Läufe derselben Version liefern je Plattform byte-identische Binaries — gemessen, nicht
      behauptet.
- [ ] **Release-Workflow:** eigene `.github/workflows/release.yml`, **tag-getrieben**, ruft **nur**
      `make`-Targets ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
      Setzung 1 — keine zweite Build-Definition im Workflow) und lädt die Artefakte ans Release.
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
- [ ] `make gates` grün · `make mutate` grün mit rot gesehener Mutation je neuem Wächter
      (Cross-Compile-Verdrahtung · `DEST`-Pflicht · Matrix-Vollständigkeit).
- [ ] `make full-smoke` unverändert grün (der Default-Pfad darf sich nicht bewegen).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

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
| `.github/workflows/release.yml` | neu | tag-getrieben (+ `workflow_dispatch`), nur `make`-Targets, Upload ans Release — **und** die Start-Smoke-Matrix (macos/windows/linux) |
| `test/` + `test/mutations/` | neu | Wächter je neuer Zusage, jeder mit rot färbender Mutation |

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

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): additive Erweiterung der
Bau-Kette (eine `Dockerfile`-Stage bekommt Build-Args, ein neues `make`-Target) und ein neuer
Workflow neben zwei bestehenden. Der Default-Pfad bleibt byte-identisch, es entsteht keine neue
Sub-Area und kein Diskrepanz-Risiko.

Einzige Ausnahme mit anderem Charakter ist der **CR am Lastenheft**: dort gilt Doc-führt — die
Präzisierung der Messmethode geht dem Code voraus, nicht umgekehrt.
