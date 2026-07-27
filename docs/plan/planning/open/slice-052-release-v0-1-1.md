# Slice slice-052: `v0.1.1` — die Nutzer-Doku sagt, was das Werkzeug tut

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Release-Nachzug — Präzedenz slice-043/047/048/049/050/051).

**Bezug:** [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (Plattform-Matrix, unverändert),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (phasierter, idempotenter Bootstrap — die Aussagen, die hier falsch sind,
beschreiben genau ihn), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Kurs-Tag ist **im Programm gepinnt**),
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) (Release-Workflow).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-26.

---

## 1. Ziel

`v0.1.1` liefert eine Nutzer-Doku aus, die **beschreibt, was das Werkzeug tut** — und der Tag
trägt sie, statt sie erst danach zu bekommen. Vier gemessene Falschaussagen fallen; zwei davon
sind seit `v0.1.0` veröffentlicht, zwei sind älter und haben zwei Releases überlebt.

## 2. Definition of Done

- [ ] **(1) Der getaggte Stand verneint seinen eigenen Release nicht mehr.** In `v0.1.0` trägt
  `docs/user/benutzerhandbuch.md` in der FAQ „Gibt es ein fertiges Download-Binary? — **Derzeit
  nicht**" (Zeile 486) und im Anhang „**keine Release-Versionsnummer**" (Zeile 524). Beides ist auf
  `main` bereits korrigiert ([slice-050](../done/slice-050-doku-nachzug-release.md) A-1) — dieser Slice bringt die Korrektur **in einen
  Tag**.
- [ ] **(2) „arbeitet in *einem* Schritt" ist weg** ([Benutzerhandbuch](../../../user/benutzerhandbuch.md) §Wichtigstes
  Bedienkonzept). Der Satz widerspricht dem **eigenen Dokument**: Zeile 4 nennt den Bootstrap
  „**phasiert** (Init sprach-agnostisch, `--lang` optional; Sprachmodule per `add-lang`)", und §11
  protokolliert, dass Handbuch **1.1** genau dieses Modell eingeführt hat. Der Satz ist ein
  Überbleibsel von davor. Korrekt: Init und Sprachmodul sind **getrennte** Schritte, `--lang` beim
  Init ist die **One-Shot-Kurzform**.
- [ ] **(3) „zieht ein neueres Regelwerk nach" ist auf das eingeschränkt, was der Code hält —
  an ALLEN Fundstellen.** Gemessen: **vier** im Handbuch (Zeilen 179, 301, 309, 489) **und eine im
  [`README.md`](../../../../README.md)** (Zeile 37) — die erste Fassung dieses Befunds sah nur eine, die Zählung steht
  hier, damit der Fix nicht auf halber Strecke endet. Der Kurs-Tag ist **im Programm gepinnt**
  (`tag := envOr("COURSE_TAG", fetch.DefaultTag)`, [`cmd/ai-harness-init/main.go`](../../../../cmd/ai-harness-init/main.go)); ein Re-Lauf
  **desselben** Binaries holt **denselben** Stand. Er heilt Drift — er hebt **nicht** auf einen
  neueren Kurs-Stand. Dafür braucht es ein **neueres Programm** oder ein bewusstes `COURSE_TAG=…`.
- [ ] **(4) Windows-Hinweis ergänzt**, symmetrisch zum vorhandenen macOS-Quarantäne-Absatz.
  **Gemessen ist:** der Workflow hat **keinen Signier-Schritt**
  (`grep -ciE "sign|codesign|signtool|authenticode" .github/workflows/release.yml` → **0**), die
  `.exe` ist also unsigniert. **Nicht gemessen ist** die Reaktion von Windows/SmartScreen — hier
  läuft kein Windows. Der Hinweis sagt deshalb **nur das Belegte** („die Programme sind nicht
  signiert; Windows kann den ersten Start deshalb mit einer Warnung unterbrechen") und behauptet
  keinen Dialog-Wortlaut, den niemand gesehen hat.
- [ ] **`spec/lastenheft.md` unberührt** über die Commits dieses Slice — Messbefehl in der
  Closure, keine Zahl ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2; die Formulierungs-Falle ist aus
  [slice-050](../done/slice-050-doku-nachzug-release.md) bekannt). Keine der vier Korrekturen ändert eine Anforderung — sie ziehen die
  Beschreibung an [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) und [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) heran.
- [ ] **Tag `v0.1.1` gesetzt, `release`-Lauf grün über alle acht Jobs, sechs Assets gezählt.**
- [ ] **Die veröffentlichten Assets sind gegen die CI-Artefakte gehalten** (sha256-Mengenvergleich,
  alle sechs). Das schließt für **dieses** Release die Lücke, die bei `v0.1.0` von Hand gefunden
  wurde: der `publish`-Schritt hat **keinen** Sensor — geprüft wird die Vorstufe, veröffentlicht
  das Produkt. Als Sensor gebaut wird das hier **nicht** (eigener Vorgang, s. §6).
- [ ] `make gates` grün. `make mutate` **nicht** erforderlich, falls kein Wächter berührt wird —
  das ist beim Abschluss zu **begründen**, nicht stillschweigend zu unterlassen.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-26, live; Kommando neben jeder Aussage — die Lehre aus slice-049/050):**

| # | Fundstelle | Kommando / Beleg |
|---|---|---|
| 1 | `v0.1.0`-Tag: FAQ Zeile 486, Anhang Zeile 524 | `git show v0.1.0:docs/user/benutzerhandbuch.md \| grep -n "Derzeit nicht\|keine Release-Versionsnummer"` |
| 2 | Handbuch Zeile 179 („einem Schritt"), **1 Treffer** | `grep -cn 'arbeitet in \*\*einem\*\* Schritt' docs/user/benutzerhandbuch.md` |
| 3 | Handbuch 179/301/309/489 (**4**) + [`README.md`](../../../../README.md) 37 (**1**) | `grep -n "neueres Regelwerk nach\|neueren Kurs-Stand" docs/user/benutzerhandbuch.md README.md` |
| 4 | kein Signier-Schritt | `grep -ciE "sign\|codesign\|signtool\|authenticode" .github/workflows/release.yml` → `0` |

**Warum (3) mehrfach steht und das der eigentliche Fallstrick ist:** dieselbe Aussage ist an fünf
Stellen ausformuliert. Wer nur die zitierte Stelle korrigiert, hinterlässt vier weitere — und der
nächste Leser findet genau eine davon. Der Fix ist erst vollständig, wenn das Kommando aus Zeile 3
der Tabelle keinen unkorrigierten Treffer mehr liefert.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md) | update | (2) Bedienkonzept, (3) vier Stellen, (4) Windows-Hinweis; §11-Zeile + Handbuch-Version |
| [`README.md`](../../../../README.md) | update | (3) die fünfte Fundstelle |
| `spec/lastenheft.md` | **unberührt** | keine Anforderung ändert sich |

**Reihenfolge:** (1) alle vier Korrekturen, (2) `make gates`, (3) Review + Verifikation,
(4) Tag `v0.1.1` **aus dem korrigierten Commit** — die Reihenfolge aus [slice-050](../done/slice-050-doku-nachzug-release.md), damit der
veröffentlichte Stand die richtige Doku trägt, (5) Assets zählen und gegen die CI-Artefakte halten,
(6) Closure.

## 4. Trigger

**`open` → `in-progress`:** die vier Befunde sind gemessen (§3); zwei davon (1) sind seit `v0.1.0`
veröffentlicht. **Alle vier fand ein Mensch beim Lesen, kein Sensor** — (1) im Review zu
[slice-050](../done/slice-050-doku-nachzug-release.md), (2)–(4) durch Nutzer-Fragen. Voraussetzung: [slice-051](../done/slice-051-artifact-dest-anlegen.md) ist
geschlossen — sein `DEST`-Fix soll **mit** `v0.1.1` ausgeliefert werden, nicht danach.

Rückführungen:

- `in-progress` → `open`: falls eine der Korrekturen eine **Anforderungs**-Änderung erzwingt (dann
  eigener CR nach [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler), kein Nebeneffekt), oder falls der `release`-Lauf auf dem
  echten Tag rot wird.
- `in-progress` → `next`: falls der Windows-Hinweis eine echte Messung auf Windows verlangt, statt
  sich auf das Belegte zu beschränken — dann ist das ein eigener Zuschnitt mit eigener Umgebung.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) — **ein Verdikt muss ausgestellt sein**, nicht nur
Findings aufgelöst; Verifikation bestätigt die DoD (Modul 11); `make gates` grün; Tag `v0.1.1`
gepusht, `release`-Lauf grün über alle acht Jobs, sechs Assets gezählt **und** gegen die
CI-Artefakte gehalten; Slice per `git mv` nach `done/` (eigener Move-Commit,
Link-Reconciliation im Folge-Commit); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Fix ist eine Aufzählung — und Aufzählungen waren heute fünfmal unvollständig.** Deshalb
  steht in §3 je Punkt das **Kommando**, nicht die Zahl allein; die Vollständigkeit ist am Ende
  **damit** zu belegen, nicht durch Durchsehen.
- **(4) ist bewusst schwächer formuliert als die Erwartung.** Dass eine unsignierte `.exe` unter
  Windows eine SmartScreen-Warnung auslöst, ist plausibel und **nicht gemessen**. Der Hinweis sagt
  nur, was belegt ist. Wer Windows hat, kann daraus später eine belegte Aussage machen.
- **Das Zeitfenster zwischen Doku-Commit und Tag** ist wie bei [slice-050](../done/slice-050-doku-nachzug-release.md) unvermeidbar und
  **benannt**, nicht wegdefiniert.
- **Der `publish`-Schritt bleibt ohne Sensor.** Dieser Slice prüft die Assets **von Hand** — das
  deckt `v0.1.1`, nicht die Klasse. Der Sensor (ein Job **nach** `publish`, der die
  veröffentlichten Assets gegen die CI-Artefakte hält) gehört zum Roadmap-Kandidaten *Regeln ohne
  Feedback-Quadrant schließen*, Achse „veröffentlichte Artefakte außerhalb von git".
- **Ein Tag ist nach außen wirkend und schlecht umkehrbar** — Zustimmung des Nutzers vor dem Push,
  wie bei `v0.1.0`.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

**Alle berührten Sub-Areas GF** (siehe Kurs Modul 5 §Worked Mini-Example): die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) führt `*` (gesamtes Repo) als **Greenfield**. Die berührte Sub-Area
*Nutzer-Dokumentation* ([`README.md`](../../../../README.md) + [`docs/user/`](../../../user/benutzerhandbuch.md)) ist in diesem Repo entstanden und
vollständig bekannt.

Der Vollblock entfällt damit laut Template. **Anmerkung:** dieser Slice hat wie
[slice-050](../done/slice-050-doku-nachzug-release.md) eine **nach außen wirkende** Achse (der Tag) — kein Modus-Thema, sondern eine
Freigabe-Frage; sie steht in §5 und §6.
