# Slice slice-070: `comment-claims` meldet Vollständigkeit über einen dreifach verengten Prüfbereich

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Sensor-Wartung) — der Befund entstand bei
[slice-060](../done/slice-060-rollen-achse.md), betrifft aber jede Datei des Repos.

**Bezug:** [`AGENTS.md`](../../../../AGENTS.md) §3.6 (die Regel, die `comment-claims`
durchsetzt),
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
(die Sensor-Mechanik),
[`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
(der Gate-Stempel, dessen Umfang hier auseinanderfällt).

**Bewusst KEINE `LH-*`-Kennung.** Geprüft: die zwölf Anforderungen betreffen das emittierte
Zielprojekt; dieser Slice repariert einen Dogfood-Sensor. Die naheliegende
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
verlangt *„jeder **emittierte** Gate-Target läuft auf frischem Checkout"* — die andere Ebene.
Leer und erkennbar statt gefüllt und falsch.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-30.

---

## 1. Ziel

**Die Zeile „N Datei(en) geprueft, 0 Befund(e)" soll sagen, was sie behauptet.**

`make comment-claims` verengt seinen Prüfbereich gegen den Gate-Stempel **dreifach**:

1. **nur getrackt** — `git ls-files` **ohne** `--others`, während der Stempel
   `git ls-files -z --cached --others --exclude-standard` listet
   (`harness/tools/working-tree-hash.sh`). Eine neue, noch nicht getrackte Datei liegt
   **innerhalb** des bestätigten Baum-Zustands und **außerhalb** des Prüfbereichs.
2. **nur vier Pfad-Muster** — `internal/**/*.go`, `cmd/**/*.go`, `harness/tools/*.sh`,
   `.claude/hooks/*.sh`.
3. **Test-Dateien ausgenommen** — `grep -v '_test[.]go'`.

Nur (1) heilt ein `git add`; (2) und (3) sind **permanent**.

**Zwei gemessene Folgen, beide in einer Sitzung aufgetreten:**

- `internal/span/response.go` lag beim Abschluss-Lauf untrackt. Das Gate meldete *„37
  Datei(en) geprueft, 0 Befund(e)"* — die Datei mit **zehn** Sensor-Nennungen war nie
  angesehen worden. Post-commit waren es 38.
- Das **eigene `Makefile`** trägt eine Behauptung (`:83`), die `comment-claims` findet, sobald
  man es von Hand darauf zeigt — im Gate-Lauf aber nie sieht. Dauerhaft ungeprüft sind
  außerdem `harness/tools/*.awk` (drei Dateien, darunter der in slice-060 gebaute
  `extract-agent-call.awk`), `internal/emit/templates/`, `test/`, `.codex/`, `.github/` und
  **jede** Markdown-Datei — also auch `harness/conventions.md`, wo die bindenden Adaptionen
  stehen.

**Ein zweiter, unabhängiger Defekt derselben Datei:** die Ausnahme für Verneinungen
(*„ein grüner Gate belegt NICHT, dass er greift"* ist eine Warnung, keine Zusage) hat ein
Fenster von **zwölf** Zeichen zwischen Verb und Verneinung. Der `Makefile:83`-Fall braucht
**dreizehn** — die Ausnahme verfehlt ihn um ein Zeichen und erzeugt so einen Falsch-Treffer.

## 2. Definition of Done

- [ ] **(1) Der Prüfbereich und die gemeldete Zahl sagen dasselbe.** Entweder wächst der
  Bereich, oder die Meldezeile nennt ihren Umfang — **beides ist zulässig, Schweigen nicht.**
  Eine Zeile „N Dateien geprüft" ohne Angabe, aus welcher Menge N stammt, ist die
  Vollständigkeits-Behauptung, gegen die dieser Slice steht. **Achse (1) ist gesondert zu
  entscheiden:** untrackte Dateien mitzuprüfen ist billig und schließt die gemessene Lücke,
  ändert aber das Verhältnis zum Stempel — das gehört begründet, nicht nebenbei.
- [ ] **(2) Das Negations-Fenster ist entschieden, nicht geraten.** Zwölf Zeichen sind eine
  Zahl ohne Herleitung. Entweder eine begründete Weite, oder eine andere Erkennung der
  Verneinung. **Der Zahn ist der `Makefile:83`-Fall selbst** — er ist bis dahin **nicht** zu
  entschärfen: ihn umzuformulieren entfernte das Gegenbeispiel, an dem die Entscheidung
  gemessen wird.
- [ ] **(3) Beide Änderungen haben je einen rot gesehenen Zahn**
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Für den Prüfbereich heißt das: eine Datei, die
  **vor** der Änderung stillschweigend durchfiel, muss **nach** ihr einen Befund erzeugen —
  und der Fall muss rot werden, wenn jemand den Bereich wieder verengt. Ein Gate, das seinen
  eigenen Umfang nicht bewacht, wiederholt genau den Fehler.
- [ ] `make gates` grün; `make mutate` über die CI grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`Makefile`](../../../../Makefile) | update | der Prüfbereich aus DoD (1) |
| `harness/tools/comment-claims.sh` | update | das Negations-Fenster aus DoD (2), ggf. die Meldezeile |
| `test/comment-claims.bats` | update | die Zähne aus DoD (3) |
| `test/mutations/` | neu | die Dauer-Sensoren zu DoD (3) |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | die Festlegungen in [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) |

**Ist-Messung vor dem Code** (Modul 9 §4): der Bereich wächst — wie viele **echte** Befunde
entstehen dabei? Der `Makefile:83`-Fall ist einer; ob `harness/tools/*.awk`,
`internal/emit/templates/` und `test/` weitere tragen, ist heute **nicht gemessen** (für die
`.awk`-Dateien wurde einmal `0 Befunde` gemessen — eine Aussage über heute, nicht über die
Abdeckung). Ein Bereich, der beim Anschalten hundert Befunde wirft, ist ein anderer Slice.

## 4. Trigger

**`open` → `next`:** [slice-060](../done/slice-060-rollen-achse.md) ist **done** —
WIP-Limit, und slice-060 schreibt weiter Kommentare in den Prüfbereich.

**`next` → `in-progress`:** WIP-Limit; dazu die Ist-Messung aus §3, weil sie über den Schnitt
entscheidet.

Rückführungen:

- `in-progress` → `next`: falls die Ist-Messung viele Bestands-Befunde zeigt — dann trennt ein
  Re-Slice die Bereichs-Erweiterung von deren Abarbeitung.
- `in-progress` → `open`: falls sich zeigt, dass die Erweiterung auf Markdown eine andere
  Erkennung braucht als die auf Quelltext. Dann ist erst die Form zu entscheiden.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt (Modul 11); `make gates`
grün und ein CI-Vollauf `make mutate` mit `0 Befund(e)`; `git mv` nach `done/` (eigener
Move-Commit); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Bereich zu weiten heißt, Befunde zu erben.** Jeder echte Befund ist Arbeit, die dieser
  Slice nicht eingeplant hat — deshalb die Ist-Messung **vor** dem Schnitt der Umsetzung.
- **Markdown ist nicht Quelltext.** `harness/conventions.md` trägt Zusagen in Prosa; eine
  Erkennung, die für Go-Kommentare gebaut ist, erzeugt dort womöglich Rauschen. Dass die
  bindenden Adaptionen heute **völlig** ungeprüft sind, ist trotzdem der schwerste Teil des
  Befunds.
- **Gate-Anhebung, kein Carveout** ([`AGENTS.md`](../../../../AGENTS.md) §3.5): der Prüfumfang
  **wächst**, er schrumpft nicht. Nach
  [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  ist das ein Steering-Loop und braucht kein ADR — aber es gehört gesagt.
- **Dieser Slice heilt die Klasse NICHT**, die ihn ausgelöst hat. Ein perfekt gescopetes
  `comment-claims` prüft weiterhin nur, dass ein genannter Sensor **existiert** — nie, ob er
  die genannte Zusicherung **bindet**. Das ist
  [slice-069](slice-069-zahn-bindet-zusicherung.md); beide zusammen decken die Wurzel, keiner
  allein.
- **Nicht in diesem Slice:** die emittierte Ebene. Ob ein bootstrapptes Ziel denselben Sensor
  bekommt, entscheidet slice-062/063.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `harness/` und `test/`
gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
