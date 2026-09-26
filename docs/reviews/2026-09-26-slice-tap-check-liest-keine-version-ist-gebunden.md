# Review-Report: slice-tap-check-liest-keine-version-ist-gebunden — 2026-09-26

**Review-Art:** Test-, Mutations- und Doku-Diff gegen Plan, ADR und Hard Rules (Modul 10). Nicht gegen die DoD (das ist der Verifier).

**Gegenstand:** `git diff 3be0f3c4..HEAD -- test docs/user/releasing.md` (HEAD `026c1aff`, Baum sauber, Stempel gedeckt) plus die
Move-/Marker-Commits `0a0494e0` (`make slice-mv`, reiner Move `next/` → `in-progress/`), `c39a9acc` (`make slice-mv`, ein Verweis
nachgezogen), `7551a7c4` (Rolle Implementer: Ruhe-Marker der Roadmap entfernt, drei Zeilen). Produktiv-Diff: `cf186c0c` (bats-Fall
`check liest keine Version …` in `test/tap-nachzug.bats`, Mutations-Fall 452) und `026c1aff` (`docs/user/releasing.md`, Schritt 7).

**Plan-Bezug:** Slice `slice-tap-check-liest-keine-version-ist-gebunden` (Ziel, §1 Abgrenzung, §2 Liefer-Punkte als Prüfmaßstab der
Zusage-Form, §3, §6) — Kennung, nicht Pfad: der Plan wandert mit dem Lifecycle (`AGENTS.md` §3.11). **Constraint:** `ADR-0064`
(`Accepted`, Festlegung 2 und §Fitness Function), `ADR-0066` (`Accepted`, Festlegung 2), `LH-QA-02`, `MR-071`, `AGENTS.md` §3.6,
§3.7, §3.10, §3.11, Setzung des Auftraggebers *„die Nutzerdoku trägt nur den Ist-Zustand"*.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** Sonnet 5 · **Datum:** 2026-09-26

**Eingangs-Kontext:** Diff · Slice-Plan · `ADR-0064` · `ADR-0066` · `MR-071` · `LH-QA-02` · `AGENTS.md` §3 · `harness/tools/tap-nachzug.sh`
und `harness/tools/tap-nachzug-nutzlast.sh` · `test/tap-nachzug.bats` · `test/mutations/409` bis `434` · `docs/user/releasing.md` ·
`harness/README.md`. Der Implementer-Bericht war Behauptung; Fall, Anker, Text und Läufe sind selbst gelesen und gefahren.

**Eigene Sensor-Läufe dieses Laufs** — alle in Scratchpad-Kopien von `git archive HEAD` (kein `.git`), Docker-only im bats-Bild des
Makefiles (`docker run --rm --network none -v <Kopie>:/code:ro … test/tap-nachzug.bats`); kein Schreibzugriff im Repo-Baum, kein
Tap-Zugriff, kein `make mutate`:

| Lauf | Ergebnis |
|---|---|
| unverändert, `test/tap-nachzug.bats` | `1..38`, kein `not ok` |
| Mutation 452 angewandt (`bash test/mutations/452-…sh` in der Kopie) | Anker trifft Zeile 110 von `tap-nachzug-nutzlast.sh` (`diff` gegen die Kopie: genau eine Zeile geändert, `bash -n` ok); **genau ein** `not ok`: `13 check liest keine Version: ungleiche Bytes …` mit `Exit 0, stdout: tap-check: gleich — Tag v0.2.3 …` — der Name trägt den `# expect:`-Text, die Meldung ist die behauptete Ursache (der Vergleich endet gleich statt Formel-Unterschied) |
| Mutation 452, Fall 13 aus der Kopie entfernt (Gegenprobe 1) | `test/tap-nachzug.bats`: `1..37`, **grün**; ganze Suite `test/` (388): einziges `not ok` ist `driver: die Kopie traegt den Sensor-Bedarf inklusive .git` (bekanntes Kopie-Artefakt, `.git` fehlt) — **kein anderer Fall** deckt die Stelle |
| Mutation 452, Fall 13 auf kleinere Version geschwächt (`0.2.2` statt `0.2.4`, Assertion angepasst; Gegenprobe 2) | `1..38`, **grün** — der Fall bindet die Größer-Richtung, nicht die Mutation im Allgemeinen |
| alle 27 Fälle der Familie (`409` bis `434`, `452`), je Fall in frischer Kopie angewandt | jeder Anker wirkt (Kopie unterscheidet sich vom Bestand), jeder Fall färbt **einen Fall mit seinem `# expect:`-Text** rot; `452` färbt genau 1, kein Fall der Familie hat seine Wirkung verloren; keine `# expect:`-Zeile eines anderen Falls ist Teilzeichenkette des neuen Fall-Namens (Kollisions-Schleife: keine Treffer) |
| Ersatz-Mutation „kleinere Tap-Version gilt als gleich" (`sort … head -n 1`) | rot: `3 vorfall nachgestellt`, `30 exit-zeile`, `35 unterschied` |
| Ersatz-Mutation „gleiche `version`-Zeile bei ungleichen Bytes gilt als gleich" | rot: `2`, `4`, `8`, `9`, `11` |
| Ersatz-Mutation „Tap-Version größer **und** mehr als eine Zeile weicht ab gilt als gleich" | `1..38`, **kein** `not ok` — überlebt |
| `git ls-files -s test/mutations/452-…sh` | Modus `100755`, wie `409` bis `434` |
| `grep -cP '^\t1\) return 1 ;;$' harness/tools/tap-nachzug-nutzlast.sh` | `1` (Zeile 110); `grep -n 'return 1 ;;' harness/tools/tap-nachzug*.sh` nennt nur diese Zeile |
| `grep -c '^@test' test/tap-nachzug.bats`; `grep -c 'check liest keine Version' test/tap-nachzug.bats` | `38`; `1` |

---

## Findings

Kein HIGH.

### MEDIUM

**R1-1** — `kategorie`: MEDIUM · `quelle`: `AGENTS.md` §3.6 (die Zusage trägt, was der Code hält), Setzung *Ist-Zustand*, `ADR-0064` §Fitness Function ·
`pfad`: `docs/user/releasing.md:176-179` · `befund`: *„**Nicht gebunden** ist jede andere Form der Versions-Lektüre: eine
kleinere Tap-Version und eine gleiche `version`-Zeile bei sonst ungleichen Bytes"* nennt zwei Formen als ungebunden, die
`test/tap-nachzug.bats` bindet: ein Vergleich, der eine kleinere Tap-Version als gleich gelten lässt, färbt drei Fälle (3, 30,
35), einer, der eine gleiche `version`-Zeile bei ungleichen Bytes als gleich gelten lässt, fünf (2, 4, 8, 9, 11). Der
Nachsatz *„nicht Gegenstand dieses Falls"* ist wahr, die Überschrift *„Nicht gebunden"* über der ganzen Suite ist es nicht. Eine Form, die
die 38 Fälle tatsächlich nicht färbt (Tap-Version größer **und** weitere Zeilen weichen ab), steht nicht da. ·
`verifizierbar`: ja — die zwei Ersatz-Mutationen und die dritte oben in Scratchpad-Kopie (`not ok` bzw. `1..38` ohne Befund). ·
`klasse`: *Doku-Zusage nennt als ungebunden, was die Suite über einen anderen Fall bindet — „nicht gebunden" ohne Suite-Messung*

### LOW

**R1-2** — `kategorie`: LOW · `quelle`: `AGENTS.md` §3.6, Setzung *Ist-Zustand* (M-1 der Kurzrunde: die Aussage nicht weiter ziehen als
gebunden) · `pfad`: `docs/user/releasing.md:174-176` · `befund`: *„ein Vergleich, der bei ungleichen Bytes die `version`-Zeilen liest
und bei größerer Tap-Version mit Exit 0 endet, färbt ihn"* ist als Allsatz formuliert; eine Variante, die genau das tut, aber nur
bei zusätzlich weiteren abweichenden Zeilen (Ersatz-Mutation 3 oben), färbt Fall und Suite nicht. Gebunden ist die Form der
Mutation 452 (Tap-Version größer, sonst nichts anders), nicht jeder Vergleich, der die Beschreibung erfüllt. · `verifizierbar`: ja —
Ersatz-Mutation 3 (`1..38`, kein `not ok`). · `klasse`: *Zusage über „ein Vergleich, der …" bindet die eine Mutations-Form, nicht die Beschreibung*

### INFO

**R1-3** — `kategorie`: INFO · `quelle`: `MR-025` · `pfad`: `docs/user/releasing.md:179` · `befund`: Die Zahl `38` steht neben dem
richtigen Kommando (`grep -c '^@test' test/tap-nachzug.bats` → `38`, gemessen), hängt aber an keiner Aussage: sie stützt seit der
Umformulierung weder „ungebunden" noch „gebunden", steht nach einem Semikolon in einem Satz über den Gegenstand des Falls. Ohne
Bezugsaussage ist sie eine Zahl ohne Zusage. · `verifizierbar`: nein · `klasse`: *Zahl neben Kommando ohne die Aussage, die sie stützt*

**R1-4** — `kategorie`: INFO · `quelle`: Modul 10 (Berührungspunkt, Kennung nur nennen) · `pfad`: `docs/user/releasing.md:163-185` ·
`befund`: Der Absatz *Grenze* ist der Gegenstand, den `slice-tap-nachzug-sync-schreibt-die-formel-ins-tap` (`open/`) in seinem
Liefer-Punkt 3 umschreibt (*„Bytes, keine Versionen"*, das Kommando `grep -ci version …`, *„Vorwärts-Schutz allein bei der
Vorbedingung"*). Der Satz *„der Zahn fehlt"*, den dieser Plan als fremden Bestand nennt, steht nach dem Diff nicht mehr
(`grep -n 'der Zahn fehlt' docs/user/releasing.md` → kein Treffer); sein Text nimmt den Absatz „in dem Stand, in dem er liegt" und bleibt
in dieser Formulierung richtig. Die Datei jenes Slice ist nicht angefasst. · `verifizierbar`: ja · `klasse`: *zwei offene Slices berühren
denselben Absatz einer Nutzer-Doku*

**R1-5** — `kategorie`: INFO · `quelle`: Maintainability · `pfad`: `test/tap-nachzug.bats:270-274` · `befund`: Unter Mutation 452 bricht
die erste Assertion (`status`) den Fall ab; die Assertions auf `Formel-Unterschied`, Tap-Version, `tap-check: Exit 1` und zwei
Lesungen werden dort nicht mehr erreicht. Sie beschreiben die gebundene Form vollständig (Exit, Meldung, Klassenzeile, Wiederholung),
gebunden werden sie je durch die Fälle 2/3, 30 und 3. Kein Mangel, nur eine Auskunft, warum ein Zahn sie einzeln nicht belegt. ·
`verifizierbar`: ja · `klasse`: *Assertion eines Falls unter der gewählten Mutation nicht erreicht*

---

## Geprüft, ohne Befund

- **bats-Fall (`test/tap-nachzug.bats:262-275`) bindet die Eigenschaft, nicht die Implementierung:** `check` liest die Version nicht,
  soweit sie beobachtbar ist — Tap-Version größer bei ungleichen Bytes ⇒ Exit 1. Auf unverändertem Code grün, unter der Mutation der
  Kurzrunde rot (`Exit 0 … gleich`), Gegenprobe (Fall entfernt) grün, Gegenprobe 2 (Fall auf Gleichstand/kleiner geschwächt) grün — der
  Fall bindet genau die Größer-Richtung. Assertions vollständig gegen den Auftrag: Exit 1 · `Formel-Unterschied` · `Tap [  version "0.2.4"]` ·
  letzte stderr-Zeile `tap-check: Exit 1` · zwei Tap-Lesungen.
- **Erwartung aus dem geprüften Gegenstand:** keine. Alle Erwartungswerte sind Literale oder Fixture (`0.2.4`, `Formel-Unterschied`,
  `tap-check: Exit 1`, `2`); die Vorbedingung `digest(asset) != digest(tap024)` prüft die Fixture, nicht den Code (kann unter keiner
  Code-Mutation rot werden und will es nicht — sie schützt den Fall vor dem Leerlauf bei gleichen Bytes).
- **Kommentar im Fall:** Zustandsform, Klasse *Abgrenzung/Zusage*, auf die gebundene Form eingeschränkt; die Nennung von `vorfall nachgestellt`
  ist ein Zeiger auf einen bestehenden Fall, keine Chronik. Kein Konjunktiv.
- **Mutations-Fall 452:** Kopf vollständig (`# files:` eine Datei, `# expect:` Präfix des Fall-Namens, `# verify: test-bats` wie alle 27
  der Familie), Modus `100755`, `\x24`-Konvention wie in vier weiteren Fällen des Verzeichnisses, `set -euo pipefail`, Nummer 452 frei. Anker
  nach MR-071 gegen den Quell-Bestand gemessen: genau eine Zeile (110). Kopfkommentar in Zustandsform, beschreibt Wirkung und Rot-Fall,
  Abgrenzung (*kleinere Tap-Version … färbt dieser Fall nicht*) stimmt mit den Messungen überein (die Mutation feuert dort nicht).
- **Stichprobe 411, 427, 434 und die ganze Familie 409 bis 434:** keiner verliert seinen Zahn, kein Anker verschoben; neuer Fall-Name kollidiert
  mit keinem `# expect:`.
- **`docs/user/releasing.md`, Schritt 7 — übrige Aussagen:** *„gleiche Bytes enden mit Exit 0, auch mit einer `version`-Zeile außerhalb
  der Feldform und ohne jede `version`-Zeile"* (Fall `version-zeile: in check …`), *„größere Tap-Version … Exit 1, Meldung, `tap-check: Exit 1`"*
  (Fall 13), Mutations-Fall mit Pfad, beide `grep -n`-Kommandos treffen je genau den benannten Fall, `38` gemessen. Zustandsform, keine
  Chronik, kein Konjunktiv, keine Rolle, kein Klon-Pfad. Schritt-Nummerierung unverändert (`Schritt 7` in Zeile 188/194 zeigt auf
  `tap-check`, `Schritte 4 und 6` in Zeile 206 unberührt); `harness/README.md` (Zeile `make tap-check`) sagt nichts über die Version und
  ist nicht berührt (Doku-Update-DoD: entfällt, stimmt).
- **§3.10:** kein Closure-Artefakt in den Commits — die DoD-Haken der Slice-Datei sind unberührt, keine Closure-Notiz. **§3.3:** `0a0494e0` ist ein reiner
  Move (100 %), das Nachziehen `c39a9acc` ein eigener Commit. **§3.11:** dieser Report nennt den Slice nur bei der Kennung; die Marker-Entfernung in
  der Roadmap folgt dem Bestand (zwei Vorgänger-Slices, Wiederherstellung beim Planner-Abschluss).
- **HIGH-Liste des Skills, Punkt für Punkt:** ADR-/Hard-Rule-Verstoß — keiner (§3.6 Gegenprobe fährt der Fall selbst, §3.7 sauber, §3.9 eingehalten, Docker-only) ·
  Gate-Lockerung ohne ADR — keine · Stilles-Grün-Pfad — keiner (der Fall färbt rot, wenn der Vergleich Versionen liest) · halluziniertes Gate — keins (kein neues
  Target, nur Fall und Mutations-Fall) · superseded ADR — nein, beide Bezüge `Accepted` · Norm nur im Template-Kommentar — nein · Kommentar ohne Klasse — nein ·
  Zustandsfeld mit Chronik — nein (kein Zustandsfeld berührt außer der Roadmap-Marker-Entfernung, reine Löschung).
- **`make gates`** über dem Baum mit diesem Report: Exit 0 (darin `shell-lint` mit `test/mutations/*.sh` im Prüfbereich, `docs-check`, `test`, `comment-claims` → 77 Dateien, 0 Befunde).

**Summary:** 0 HIGH · 1 MEDIUM · 1 LOW · 3 INFO

**Finding-Klassen dieses Laufs:** Doku-Zusage nennt als ungebunden, was die Suite über einen anderen Fall bindet · Zusage über „ein Vergleich, der …" bindet die eine
Mutations-Form, nicht die Beschreibung · Zahl neben Kommando ohne die Aussage, die sie stützt · zwei offene Slices berühren denselben Absatz einer Nutzer-Doku ·
Assertion eines Falls unter der gewählten Mutation nicht erreicht

## Verdikt

**Kein HIGH; ein MEDIUM vor dem Merge zu klären.** Der Zahn selbst trägt: Fall und Mutations-Fall sind richtig gebaut, der Anker trifft eine Stelle, der Fall
wird aus dem behaupteten Grund rot und ist die einzige Deckung (Gegenprobe grün ohne ihn), die Familie ist unbeschädigt. Der Text (R1-1) sagt an einer
Stelle *ungebunden*, wo die Suite bindet — die Zusage-Klasse des Slice, jetzt in der Gegenrichtung.

**Übergabe:**

- **R1-1, R1-2 → Implementer** (Wortlaut in `docs/user/releasing.md`; Korrektur dort, nicht in diesem Lauf). Bindeglied ist die Messung der Suite, nicht des Falls: was
  die Suite nicht färbt, ist die Form *größere Tap-Version bei weiteren abweichenden Zeilen*.
- **R1-1 → Planner** zusätzlich: der Plan formuliert den Ausschluss als *„bindet der Fall nicht"* (wahr); der Doku-Satz überträgt ihn auf *„nicht gebunden"*
  (falsch für die Suite). Ob Liefer-Punkt 3 dafür geschärft wird, ist Planner-Entscheidung.
- **R1-4 → Planner:** der Nachbar-Slice für `sync` nimmt den Absatz an seinem Start in dem Stand, den er dann hat; kein Eingriff jetzt.
- Die **Finding-Klassen** gehen in die Slice-Closure §7 und von dort in den Zähler (Klasse 1 hat einen Vorgänger im Register:
  `BEO-ALL/doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst`). Dieser Report ist ein Lauf-Beleg und ersetzt keine Verifikation: DoD-Konformität und die
  Closure-Schritte prüft der Verifier bzw. schreibt der Planner (`AGENTS.md` §3.10).
