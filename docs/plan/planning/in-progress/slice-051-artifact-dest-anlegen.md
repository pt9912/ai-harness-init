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

- [x] **Der Nutzer-Befund ist behoben:** `make artifact DEST=<nicht existierendes Verzeichnis>`
  endet mit **Exit 0** und legt das Binary ab. Gegenprobe: derselbe Aufruf ist **vor** dem Fix
  Exit 2 (in §3 real gemessen).
- [x] **Beide Targets, nicht nur das gemeldete:** `release-artifacts` trägt denselben Defekt und
  wird mitgezogen.
- [x] **Die Logik lebt als Skript im Repo** unter `harness/tools/`, die Recipes **rufen** sie nur
  ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) Setzung 1, Präzedenz [`harness/tools/start-smoke.sh`](../../../../harness/tools/start-smoke.sh)). Grund ist nicht Ästhetik:
  **nur so ist das Verhalten netzlos testbar** (§3).
- [x] **Verhaltens-Wächter in bats — lokal und in CI, ohne Docker-Daemon:** ein Test stubbt
  `docker` über `PATH` (Präzedenz [`test/release-matrix.bats`](../../../../test/release-matrix.bats), Test „start-smoke nimmt die
  uebergebene Datei"), zeigt `DEST` auf ein **nicht existierendes** Verzeichnis unter `mktemp -d`
  und prüft: Exit 0, Verzeichnis angelegt, Datei am erwarteten Ort. Läuft in `make test` →
  `make gates` → CI pro Push.
- [x] **Mutations-Fall `test/mutations/86-…`** (nächste freie Nummer, in §3 gemessen): nimmt dem
  Skript das `mkdir -p` und **erwartet den bats-Test rot**. Ohne diesen Fall wäre der Wächter
  selbst ungewacht ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [x] **Der Workaround in der CI fällt weg:** `- run: mkdir -p dist` in
  [`.github/workflows/release.yml`](../../../../.github/workflows/release.yml) wird entfernt. Damit fährt **jeder Release-Lauf** den
  Fall real auf sechs Plattformen — und die Bau-Logik verlässt die YAML
  ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) Setzung 1).
- [x] **Der irreführende Handbuch-Hinweis ist korrigiert:** er deckt heute nur den fehlenden
  **Parameter** („verlangt die Angabe `DEST`"), nicht das fehlende **Verzeichnis** — und die reale
  Meldung im zweiten Fall kommt von `docker cp`, nicht vom Werkzeug.
- [x] `make gates` grün · `make mutate` grün (der neue Fall färbt seinen eigenen Wächter rot).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

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

**Was hat funktioniert.** Die Reihenfolge aus §3 hat getragen: erst **messen**, dann bauen. Dass die
Logik ein Skript werden musste, ist nicht als Ästhetik behauptet, sondern **vorher** am gepinnten
bats-Image gemessen worden (kein `make`, keine docker-CLI darin) — der Verifier hat dieselbe Messung
unabhängig wiederholt. Der in §6 benannte Fallstrick ist **nicht** eingetreten: die Wächter hängen an
der beobachtbaren Wirkung (Verzeichnis da, Datei nicht leer), nicht am Stub-Aufruf; belegt durch
Einzel-Proben je Mutation gegen je eine eigene Kopie. Und das Entfernen von `mkdir -p dist` verlegt
den Beweis von der Behauptung in den Ernstfall: der Release-Lauf fährt den Fall jetzt real auf sechs
Plattformen, weil `dist` ungetrackt ist und kein Step es vorher anlegt.

**Was anders lief als geplant — und es ist das Eigentliche.** Der Plan sah **einen** Wächter und
**einen** Mutations-Fall vor. Geliefert sind **sechs** Wächter (96–101) und **fünf** Fälle (86–90).
Der Zuwachs kam nicht aus Gründlichkeit, sondern aus fremden Augen: **jede Runde fand genau die
Hälfte, die die vorige Auflösung liegen gelassen hatte** — und zwar an **einer einzigen Zusage**,
„der Container wird immer aufgeräumt" ([`Makefile`](../../../../Makefile) Zeile 61, aus [slice-029](../done/slice-029-artifact-target.md)):

| Runde | Finder | Welche Hälfte war unbewacht | Auflösung |
|---|---|---|---|
| Review 1 (F-1) | Reviewer | **OB** überhaupt aufgeräumt wird | Test 99 + Fall 87 |
| Review 2 (N-1) | Reviewer | auch wenn `docker cp` **scheitert** | Test 100 + Fall 89 |
| Verifikation (A-1) | Verifier | das **richtige Ziel** — ein `trap` auf eine fremde ID ließ **alle** Wächter grün | Fall 90 |

Den Zerlegungs-Schritt habe ich **zweimal nicht von selbst gemacht**. Die Ursache ist benennbar und
sie ist keine Nachlässigkeit im Einzelfall: [`AGENTS.md`](../../../../AGENTS.md) §3.6 greift, wenn eine Zusage
**geschrieben** wird. Diese Zusage wurde nicht geschrieben, sondern **geerbt** — sie stand seit
[slice-029](../done/slice-029-artifact-target.md) im Recipe und ist durch diesen Slice nur in eine Datei **gewandert**, die ein
bats-Test erreichen kann. Genau diese Wanderung passiert den Filter, weil sie wie eine reine
Verschiebung aussieht, während sie in Wahrheit die erste Gelegenheit ist, die Zusage überhaupt zu
messen.

**Abweichungen — Stand bei der Closure** (aus dem Verifier-Report, `docs/reviews/2026-07-26-slice-051-verification.md`):

- **A-1 (substanziell) — behoben**, nicht vertagt: die Assertion prüfte nur `^rm `, also
  *irgendein* Aufräumen; sie prüft jetzt die ID, die `docker create` zurückgegeben hat, und Fall 90
  hält es fest. Damit ist die Zusage in drei Hälften zerlegt und jede einzeln bewacht.
- **A-3 — behoben:** `dist/` steht jetzt neben `/bin/` in der `.gitignore`. Ohne den Eintrag machte
  ein lokaler `release-artifacts`-Lauf den Arbeitsbaum schmutzig, seit `mkdir -p dist` aus der CI weg
  ist — dieselbe Klasse wie F-5, ein Verzeichnis weiter.
- **A-2 — nicht behebbar, deshalb korrigiert und in den Steering Loop gegeben** (unten).
- **A-4 — nachrichtlich:** beide Review-Reports reisen im selben Commit wie die von ihnen
  ausgelösten Auflösungen; „berichtet" und „aufgelöst" sind an der Commit-Grenze nicht trennbar. Im
  Slice konsistent gehandhabt, hier nur festgehalten.

**Steering-Loop-Einträge** (kanonische Definition:
[`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/klassifikation.md#steering-loop)):

- **Geschärfte Regel — [`AGENTS.md`](../../../../AGENTS.md) §3.6 deckt das *Schreiben* einer Zusage, nicht ihr
  *Erben*.** Vorschlag in der Sprache der Regel: *wer eine bestehende Zusage in eine erstmals
  testbare Einheit verschiebt, zerlegt sie in ihre Hälften und bewacht jede einzeln — die
  Verschiebung ist die erste Gelegenheit, sie zu messen, und damit der Zeitpunkt, zu dem §3.6
  greift.* Beleg ist nicht eine Meinung, sondern die Tabelle oben: **drei Hälften, drei Runden,
  drei verschiedene Finder**, keine davon von mir selbst.
- **Sensor-Lücke, benannt — eine Sensor-Auslassung wird mit einer Behauptung über eine Quelle
  begründet, die niemand liest (A-2).** Ich habe `make smoke` mit der Begründung ausgelassen, es sei
  „eine echte Teilmenge von `full-smoke`". Das ist **falsch**, und zwar an **zwei** Stellen des
  eigenen Repos wörtlich widerlegt (Kopf von [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) und
  [`AGENTS.md`](../../../../AGENTS.md) §4 sagen beide, `full-smoke` nehme die Sicht, die `smoke` **bewusst nicht**
  nimmt). Das Ergebnis war zufällig sauber — `make mutate` fährt `smoke` als Grün-Vorlauf. Die Klasse
  steht in §3.6 sogar als eigenes Beispiel („Byte-Gleichheit belegt `make smoke`, ohne `smoke`
  gelesen zu haben"); die Regel existiert also, ihr fehlt der **Feedback-Quadrant**: kein Gate liest
  je die Begründung, mit der ein Sensor übersprungen wurde. Das ist eine weitere Achse für den
  Roadmap-Kandidaten *Regeln ohne Feedback-Quadrant schließen*.
- **Der Auslöser selbst ist der dritte Eintrag: die Abdeckung kompensierte an der Aufrufstelle.**
  Die CI war grün, **weil sie umging** (`mkdir -p dist` vor dem Target). Der einzige unkompensierte
  Pfad war der, den [`README.md`](../../../../README.md) und das [Benutzerhandbuch](../../../user/benutzerhandbuch.md) den Nutzern
  vorschreiben — und genau dort fand ihn ein **Mensch**, kein Sensor. Kandidat: die in der
  Nutzer-Doku dokumentierten Befehle einmal **wörtlich** fahren, statt sie nur zu lesen. Das ist
  dieselbe Richtung wie der Vorschlag „Sensor **vor** dem Tag-Push" aus [slice-050](../done/slice-050-doku-nachzug-release.md) §7 und
  verstärkt ihn: dort ging es um Aussagen der Doku über den Zustand, hier um ihre **Befehle**.

**Folge-Slices.** [slice-052](../open/slice-052-release-v0-1-1.md) (`v0.1.1`) ist geschnitten und liegt in `open/` — erst er
bringt den Fix zu den Nutzern; `v0.1.0` behält ihn (§6, unverändert gültig). Die drei
Steering-Einträge sind **nicht** geschnitten (cp-Disziplin) und gehören in den Roadmap-Kandidaten
*Regeln ohne Feedback-Quadrant schließen*.

**Review und Verifikation.** Zwei Review-Runden — Runde 1 **NICHT KONFORM** (0 HIGH, 2 MEDIUM,
3 LOW, 1 INFO, merge-blockierend wegen F-1/F-2), Runde 2 **KONFORM** (0 HIGH, 0 MEDIUM, 2 LOW,
1 INFO). Verifikation: **DoD BESTÄTIGT** — 8 von 9 Punkten mit eigenen Belegen, **0 widerlegt**,
Punkt 9 (diese Notiz) zum Prüfzeitpunkt nicht fällig. Der Verifier fuhr beide Targets real
(inklusive des vollen Sechs-Plattform-Baus), `make gates`, `make mutate` mit Einzel-Proben je Fall
und baute einen Zusatz-Sensor, den niemand verlangt hatte: nach sieben realen Skript-Aufrufen meldet
`docker ps -a` **null** übrig gebliebene Container — der `trap` räumt also auch gegen den echten
Daemon auf, nicht nur im Protokoll der Attrappe.

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
