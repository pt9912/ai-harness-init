# Slice slice-051: `artifact`/`release-artifacts` legen `DEST` an — mit Wächter

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Fehlerbehebung — Präzedenz slice-026/027/043/047/048/049/050).

**Bezug:** [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (die Release-Binaries entstehen über genau diese Targets),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Wächter über leerem Prüfbereich),
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) (ein Check lebt im Repo, der Workflow-Step ruft ihn nur),
[`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md) (Docker-only).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-26.

---

## 1. Ziel

`make artifact DEST=<dir>` und `make release-artifacts DEST=<dir>` funktionieren auch dann, wenn
`<dir>` noch nicht existiert — so, wie [`README.md`](../../../../README.md) und das [Benutzerhandbuch](../../../user/benutzerhandbuch.md) es
seit `v0.1.0` vorschreiben. Und der Fix bekommt einen **Wächter, der das Verhalten misst**, nicht
nur das Vorhandensein einer Zeile.

## 2. Definition of Done

- [ ] **Der Nutzer-Befund ist behoben:** `make artifact DEST=<nicht existierendes Verzeichnis>`
  endet mit **Exit 0** und legt das Binary ab. Gegenprobe: derselbe Aufruf ist **vor** dem Fix
  Exit 2 (in §3 real gemessen).
- [ ] **Beide Targets, nicht nur das gemeldete:** `release-artifacts` trägt denselben Defekt und
  wird mitgezogen.
- [ ] **Die Logik lebt als Skript im Repo** unter `harness/tools/`, die Recipes **rufen** sie nur
  ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) Setzung 1, Präzedenz [`harness/tools/start-smoke.sh`](../../../../harness/tools/start-smoke.sh)). Grund ist nicht Ästhetik:
  **nur so ist das Verhalten netzlos testbar** (§3).
- [ ] **Verhaltens-Wächter in bats — lokal und in CI, ohne Docker-Daemon:** ein Test stubbt
  `docker` über `PATH` (Präzedenz [`test/release-matrix.bats`](../../../../test/release-matrix.bats), Test „start-smoke nimmt die
  uebergebene Datei"), zeigt `DEST` auf ein **nicht existierendes** Verzeichnis unter `mktemp -d`
  und prüft: Exit 0, Verzeichnis angelegt, Datei am erwarteten Ort. Läuft in `make test` →
  `make gates` → CI pro Push.
- [ ] **Mutations-Fall `test/mutations/86-…`** (nächste freie Nummer, in §3 gemessen): nimmt dem
  Skript das `mkdir -p` und **erwartet den bats-Test rot**. Ohne diesen Fall wäre der Wächter
  selbst ungewacht ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [ ] **Der Workaround in der CI fällt weg:** `- run: mkdir -p dist` in
  [`.github/workflows/release.yml`](../../../../.github/workflows/release.yml) wird entfernt. Damit fährt **jeder Release-Lauf** den
  Fall real auf sechs Plattformen — und die Bau-Logik verlässt die YAML
  ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) Setzung 1).
- [ ] **Der irreführende Handbuch-Hinweis ist korrigiert:** er deckt heute nur den fehlenden
  **Parameter** („verlangt die Angabe `DEST`"), nicht das fehlende **Verzeichnis** — und die reale
  Meldung im zweiten Fall kommt von `docker cp`, nicht vom Werkzeug.
- [ ] `make gates` grün · `make mutate` grün (der neue Fall färbt seinen eigenen Wächter rot).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-26, real reproduziert — Auslöser war ein Nutzer-Bericht, kein Sensor):**

- **Der Fehler, wörtlich.** `make artifact DEST=<tmp>/bin` mit nicht existierendem `<tmp>/bin`:

  ```
  invalid output path: directory "…/bin" does not exist
  make: *** [Makefile:64: artifact] Fehler 1        (Exit 2)
  ```

  Danach ist das Zielverzeichnis leer — es wird **nichts** angelegt.
- **Ursache:** beide Recipes prüfen nur `test -n "$(DEST)"` (dass der Parameter *gesetzt* ist) und
  gehen dann direkt in `docker cp`. Ein `mkdir` gibt es nirgends.
- **Beide Targets betroffen:** `artifact` **und** `release-artifacts`.
- **Warum kein Sensor es fand — der eigentliche Befund.** Die CI kompensiert den Defekt an der
  **Aufrufstelle**: [`.github/workflows/release.yml`](../../../../.github/workflows/release.yml) führt `- run: mkdir -p dist` **vor**
  `make release-artifacts DEST=dist`. Der CI-Pfad ist also grün, *weil er umgeht*; der einzige
  unkompensierte Pfad ist der, den die Nutzer-Doku vorschreibt.
- **Die Doku schreibt genau den kaputten Aufruf vor:** [`README.md`](../../../../README.md) und das
  [Benutzerhandbuch](../../../user/benutzerhandbuch.md) (Weg B) nennen `make artifact DEST=./bin` ohne `mkdir`. Der
  vorhandene Hinweis daneben deckt den *fehlenden Parameter*, nicht das *fehlende Verzeichnis*.
- **Testbarkeit — gemessen, nicht angenommen.** Das gepinnte bats-Image trägt **kein `make`** und
  **keine docker-CLI**, `/tmp` ist beschreibbar. Ein bats-Test kann das Recipe also nicht
  ausführen. **Aber die Eigenschaft braucht keinen Daemon**, und das Repo hat das Muster schon:
  [`test/release-matrix.bats`](../../../../test/release-matrix.bats) stubbt ein Kommando über `PATH` und fährt
  [`harness/tools/start-smoke.sh`](../../../../harness/tools/start-smoke.sh) real. Ein Skript + `docker`-Stub macht das Verhalten
  netzlos prüfbar.
- **Nächste freie Mutations-Nummer:** `86` (höchste vergebene: `85`).

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/artifact-copy.sh` <!-- d-check:ignore (geplant — entsteht in diesem Slice) --> | neu | `mkdir -p "$DEST"` + `docker create`/`cp`/Cleanup; die testbare Einheit |
| [`Makefile`](../../../../Makefile) | update | `artifact` und `release-artifacts` rufen das Skript statt inline zu kopieren |
| [`.github/workflows/release.yml`](../../../../.github/workflows/release.yml) | update | `mkdir -p dist` entfällt — der Ernstfall wird damit pro Release real gefahren |
| [`test/release-matrix.bats`](../../../../test/release-matrix.bats) | update | Verhaltens-Wächter mit `docker`-Stub und nicht existierendem `DEST` |
| `test/mutations/86-artifact-dest-mkdir.sh` <!-- d-check:ignore (geplant — entsteht in diesem Slice) --> | neu | nimmt das `mkdir -p` weg, erwartet den Wächter rot |
| [`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md) | update | Hinweis auf den realen Fehlerfall korrigieren |

**Reihenfolge:** (1) Skript + Recipes, (2) bats-Wächter **rot sehen** gegen den unreparierten Stand,
(3) Fix greifen lassen, (4) Mutations-Fall, (5) CI-Workaround entfernen, (6) Doku, (7) Gates.

## 4. Trigger

**`open` → `in-progress` (Implementer beginnt):** **ein Nutzer hat den Fehler berichtet** und er ist
am 2026-07-26 real reproduziert (Ausgabe in §3). Keine aktive Welle, kein Vorgänger blockiert;
[slice-050](../done/slice-050-doku-nachzug-release.md) ist geschlossen und hat den Aufruf erst prominent gemacht.

Rückführungen:

- `in-progress` → `next`: falls die Skript-Extraktion mehr Recipes berührt als die zwei (dann
  Extraktion und Fix trennen).
- `in-progress` → `open`: falls der `docker`-Stub das Verhalten nicht ehrlich abbilden kann und der
  Wächter nur noch die eigene Attrappe misst — dann ist die Testbarkeit das eigentliche Problem und
  braucht einen eigenen Zuschnitt.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt die DoD (Modul 11);
`make gates` + `make mutate` grün; der bats-Wächter wurde **einmal rot gesehen** (nicht nur grün);
Slice per `git mv` nach `done/` (eigener Move-Commit, Link-Reconciliation im Folge-Commit);
Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Stub darf nicht zum Prüfgegenstand werden.** Ein `docker`-Stub, der jeden Aufruf grün
  quittiert, macht den Test zur Selbstbestätigung. Der Wächter muss an der **beobachtbaren Wirkung**
  hängen (Verzeichnis existiert, Datei liegt am erwarteten Ort), nicht daran, dass der Stub
  aufgerufen wurde. Dieselbe Falle steht im Nachbar-Test bereits dokumentiert („der Test war grün
  aus dem falschen Grund").
- **Ein grüner Wächter belegt den Fix nicht.** Er ist erst gültig, wenn er gegen den
  **unreparierten** Stand **rot** war — deshalb steht das als eigener Schritt in der Reihenfolge
  und im Closure-Trigger ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- **Das Entfernen von `mkdir -p dist` ist eine Verhaltensänderung am Release-Pfad.** Sie ist
  gewollt (der Ernstfall wird dadurch real gefahren), aber sie zeigt sich **erst beim nächsten
  Release**. Bis dahin trägt der bats-Wächter die Aussage.
- **`v0.1.0` bleibt betroffen.** Der Fix erscheint erst in einem Folge-Release; der ausgelieferte
  Stand behält den Fehler. Das ist derselbe offene Punkt wie [slice-050](../done/slice-050-doku-nachzug-release.md) §7 A-1 und gehört in
  denselben `v0.1.1`-Vorgang.

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
*Release-/Artefakt-Pfad* (`Makefile`-Targets, [`harness/tools/`](../../../../harness/tools/), `release.yml`) ist in diesem Repo
entstanden und vollständig bekannt; die Skript-Extraktion folgt einem hier bereits gefahrenen
Muster ([`harness/tools/start-smoke.sh`](../../../../harness/tools/start-smoke.sh), slice-048).

Der Vollblock entfällt damit laut Template. **Eine Anmerkung gehört trotzdem her:** dieser Slice
entstand nicht aus einem Sensor, sondern aus einem **Nutzer-Bericht** — die Sub-Area war formal
abgedeckt (CI grün) und trug den Fehler trotzdem, weil die Abdeckung an der Aufrufstelle
kompensierte. Das ist ein Befund über die Abdeckung, nicht über den Modus.
