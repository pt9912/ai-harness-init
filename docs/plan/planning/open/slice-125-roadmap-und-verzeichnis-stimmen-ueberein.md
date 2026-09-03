# Slice slice-125: Roadmap und Lifecycle-Verzeichnis widersprechen sich nicht mehr still — und der erste Befund liegt schon vor

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) — Achse (4) des Roadmap-Kandidaten
*Regeln ohne Feedback-Quadrant schließen*. Hermetisch, hängt an keinem anderen Slice der Welle.

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist die Planungs-Ablage **dieses** Repos. Ein
emittiertes Ziel bekommt seine Gate-Konfiguration aus dem Werkzeug
([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)), und
die Frage ist dort nicht dieselbe: ein frisch gebootstrapptes Repo hat eine leere Roadmap und keine
Welle, über die ein Register urteilen könnte.

**Bezug:**
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(der Gegenstand: der Eintrag benennt seine eigene Durchsetzungs-Lücke wörtlich — *„d-checks Modul
`planning` … ist im gepinnten Image vorhanden, als `doc-planning` erzeugt und an keinen Trigger
gehängt … Bis es verdrahtet ist, lebt diese Setzung im inferential-feedforward-Quadranten"*),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Modul ohne Config-Block meldet 0 Befunde und prüft nichts — das ist der Ist-Zustand, gemessen in §1),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-*Anheben* → Steering-Loop, kein ADR),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl neben ihrem Kommando — hier besonders heikel, weil der Prüfbereich die Roadmap selbst ist),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel).

**Autor:** Planner. **Datum:** 2026-08-28.

---

## 1. Ziel

**Ein Widerspruch zwischen dem, was die Roadmap über die laufende Arbeit sagt, und dem, was in
[`in-progress/`](../in-progress) liegt, färbt `make gates` rot.**

### Der Anlass, und er ist keine Vermutung: der Befund liegt heute vor

Das Modul `planning` (`DC-FA-PLAN-001`) prüft **eine** Invariante, hermetisch und ohne git: der
Ruhe-Marker steht im Block der kanonischen Überschrift **genau dann**, wenn dort **kein**
`slice-*.md` liegt (`hasActive == hasSlices`, sonst `planning-drift`).

Gegen eine Kopie außerhalb des Repos gemessen (Stand `1f5741f`, netzlos, `:ro`, Image `v0.65.0` per
Digest), jeweils mit den Flags aus [`d-check.mk`](../../../../d-check.mk):

| Lauf | Ergebnis |
|---|---|
| `doc-planning`-Flags, **ohne** `planning:`-Block (heutiger Stand) | `425 Datei(en) geprüft, 0 Befund(e)`, **Exit 0** |
| dieselben Flags, **mit** `planning: {roadmap: docs/plan/planning/in-progress/roadmap.md}` | **1 Befund**: `planning-drift` auf [`roadmap.md`](../in-progress/roadmap.md) Zeile 13, Exit 1 |
| dieselbe Config **plus** `waves: {dir: docs/plan/planning}` | **3 Befunde**: zusätzlich `wave-drift` und `wave-preview-exists` auf `welle-09`, Exit 1 |

**Der erste Befund war echt.** Der Abschnitt hieß am Mess-Stand `## Aktuelle Welle`, nannte welle-10
und trug ausgeschriebene Trigger-Prosa, während `ls docs/plan/planning/in-progress/` allein
`roadmap.md` führte — kein Slice. Nach der Invariante war das Drift; nach der damaligen
Roadmap-Konvention war es korrekt, weil der Abschnitt **die Welle** trug und nicht den
Lifecycle-Zustand ihrer Slices.

**Die Frage ist seit [slice-136](../done/slice-136-roadmap-traegt-die-ziel-form.md) entschieden, und
zwar im zweiten Zweig: die Konvention hat sich geändert.** Der erste Abschnitt heißt
`## Offene Wellen` und trägt Zeiger plus Ruhe-Marker-Mechanik; damit gilt die Invariante des Moduls
für ihn wirklich, statt trivial. Dieser Slice zieht `heading`/`marker` also auf **diesen** Abschnitt
und muss ihn nicht mehr auf eine Sektion legen, in der nichts driften kann — der Ausgang, den
DoD (2) unten als **rot** benennt. Die Mess-Zahlen oben stehen an ihrem Stand und sind kein
Erwartungswert; der erste Schritt der Umsetzung ist, sie neu zu fahren.

**Und er ist flüchtig — das ist die zweite Hälfte derselben Beobachtung.** Über `fccc627`
(`git archive HEAD | tar -x -C <kopie>`, sonst dieselbe Kopie außerhalb des Repos, netzlos, Mount
`:ro`, Image `v0.65.0` per Digest) meldet dasselbe Profil `0 Befund(e)`, Exit 0: `in-progress/`
trägt seit dem Start von welle-10 einen Slice, und damit stimmt die Invariante wieder. Mit
`waves: {dir: docs/plan/planning}` sind es **2** Befunde (`wave-drift` auf Zeile 13,
`wave-preview-exists` auf welle-09), mit zusätzlich `mode: many` **3** (`wave-drift` je auf
welle-11 und welle-13, dazu dieselbe Vorschau-Zeile). **Ein Befund, der mit dem Wochentag kommt und
geht, taugt nicht als Abnahme-Kriterium** — was dieser Slice belegen muss, ist nicht *„der Befund
ist weg"*, sondern *„die Invariante kann in der gewählten Sektion überhaupt driften"*. Das ist der
Grund für die Form von DoD (2).

**Die zweite Fähigkeit desselben Moduls liegt außerhalb dieses Slice.** `planning` trägt neben der
Lifecycle-Invariante die **Closure-Notiz-Prüfung** (opt-in über `closure.dir`, fünf eigene
Grund-Codes); sie hat einen anderen Gegenstand (den Ruheort statt der laufenden Arbeit), eine
andere Aufruf-Empfehlung und eigene Entscheidungen. Sie ist als
[slice-129](slice-129-closure-notiz-hat-einen-sensor.md) geschnitten. **Beide Slices konfigurieren
denselben Schlüsselbaum** — sie können in beliebiger Reihenfolge laufen, aber nicht gleichzeitig.

### Die zwei Fragen, die vor dem Config-Block beantwortet sein müssen

1. **Was heißt „aktiv" in diesem Repo? — beantwortet, nicht mehr offen.** Die Invariante des Moduls
   setzt *Welle genannt* ⟺ *Slice in `in-progress/`*. Unter dem alten Abschnittsnamen galt das
   nicht: eine Welle konnte gehoben sein, während ihre Slices in `next/`/`open/` lagen. Der neue
   `## Offene Wellen` trennt beides — die **Liste** folgt den Welle-Dateien, der **Ruhe-Marker**
   folgt `in-progress/` —, und genau der Marker ist der Gegenstand der Invariante. `heading`/
   `marker` zeigen auf diesen Abschnitt.
2. **Wird die `waves`-Fähigkeit mitgenommen?** Sie ist opt-in im opt-in und liefert die zwei
   zusätzlichen Befunde. Der Prüfgegenstand ist die **Listen-Hälfte** — die Bijektion zwischen den
   Zeigern unter *Offene Wellen* und den flachen Welle-Dateien. Sie hat seit
   [slice-136](../done/slice-136-roadmap-traegt-die-ziel-form.md) zwei Vorbedingungen, die vorher
   nicht formuliert waren: `mode: many` (mehrere offene Wellen sind der Normalfall), und die dort
   an der Roadmap benannte Abweichung — dieses Repo schneidet die Welle-Datei vor dem
   Start-Trigger, es gibt also flache Dateien **ohne** Zeiger. Ein Sensor, der beides nicht kennt,
   meldet legitime Zustände als Drift. **Dieser Slice muss die Frage nicht lösen, aber er muss sie
   entscheiden** — auch mit „`waves` bleibt aus, und hier steht warum".

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3).

- [ ] **(1) `planning` ist in [`.d-check.yml`](../../../../.d-check.yml) aktiviert und läuft in
      `make gates` — über einer Invariante, die für dieses Repo wahr ist.**
      **Rot:** einen `slice-*.md` nach `in-progress/` legen, während die Roadmap-Sektion den
      Ruhe-Marker trägt (oder umgekehrt) → `make docs-check` fällt und nennt Datei, Zeile und
      `planning-drift`. Der unveränderte Baum bleibt grün. **Bleibt der unveränderte Baum nicht
      grün, ist DoD (2) nicht erledigt** — beide Läufe gehören in den Umsetzungs-Commit.
- [ ] **(2) Die gewählte Sektion kann driften, und das ist vorgeführt — nicht behauptet.** Ein
      `planning-drift` liegt je nach Tagesstand vor oder nicht (§1); abzunehmen ist deshalb nicht
      sein Verschwinden, sondern dass die Invariante über der gewählten Sektion **beide** Zustände
      annehmen kann. Aufgeschrieben ist, was in diesem Repo *aktiv* heißt und warum die gewählte
      Sektion die Invariante trägt; liegt beim Start ein Befund vor, ist er als Entscheidung
      aufgelöst und nicht wegdefiniert.
      **Rot:** die Auflösung besteht darin, `heading` auf eine Sektion zu zeigen, in der die
      Invariante trivial gilt (z. B. eine, die nie einen Marker trägt) — dann prüft das Modul über
      einer Menge, die nicht driften kann, und der Gate ist wieder das stille Grün aus §1
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
      Diese Hälfte trägt das Review; mechanisch rot wird sie nicht.
- [ ] **(3) Über die `waves`-Fähigkeit ist entschieden, und die zwei Befunde sind benannt.**
      Entweder ist sie aktiviert und `wave-drift`/`wave-preview-exists` sind aufgelöst, oder sie
      bleibt aus und der Grund steht in
      [`harness/README.md`](../../../../harness/README.md) neben dem, was der Gate **nicht** prüft.
      **Rot:** `make docs-check` meldet nach Aktivierung weiterhin einen der beiden Befunde — oder
      die Fähigkeit ist aktiviert, ohne dass `welle-09`s Lage geklärt ist, und der Gate ist ab dem
      ersten Lauf dauerhaft rot.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.d-check.yml`](../../../../.d-check.yml) | update | `planning` in `modules:` **und** der `planning:`-Block (`roadmap`, ggf. `heading`/`marker`, ggf. `waves`) — der Kern des Slice |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | update | die Auflösung des vorliegenden `planning-drift`, falls sie auf der Roadmap-Seite liegt statt in der Config |
| [`harness/README.md`](../../../../harness/README.md) | update | was der Gate prüft und was **nicht** — insbesondere die Entscheidung aus DoD (3) |
| [`docs/plan/planning/README.md`](../README.md) | ggf. update | dort steht die Aussage *„Slices tragen ihren Status über das Verzeichnis"*; wird „aktiv" hier geschärft, ist das ihr Ort |
| `test/` | neu | der Fall zu DoD (1) plus sein `test/mutations/`-Zahn |
| [`harness/conventions.md`](../../../../harness/conventions.md) | **nicht durch diesen Slice** | [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) trägt die Durchsetzungs-Aussage, die dieser Slice falsch macht — **Übergabe** an den Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8) |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md)
ist gestartet und das WIP-Limit ist frei.** Hermetisch, hängt an keinem anderen Slice der Welle.

**Eine Reihenfolge-Notiz, die kein Trigger ist:** dieser Slice ändert möglicherweise die Roadmap,
und [welle-10](../done/welle-10-re-baseline.md) ist zur Startzeit bereits geschlossen (Welle-Trigger).
Der Drift-Befund aus §1 hängt am Zustand *„Welle genannt, `in-progress/` leer"* — er kann bis dahin
verschwunden oder ein anderer geworden sein. **Die Messung ist an ihrem Stand festgemacht
(`1f5741f`) und ist kein Erwartungswert**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); der erste Schritt der Umsetzung ist, sie neu zu fahren.

**Rückführungen, vorab benannt:**

- `in-progress` → `next`: DoD (2) und DoD (3) erweisen sich als zwei Entscheidungen mit je eigenem
  Prüfbereich (Lifecycle-Invariante gegen Wellen-Register). Dann ist `waves` ein eigener Slice und
  dieser trägt nur die erste Fähigkeit.
- `in-progress` → `open`: die Invariante des Moduls ist mit
  [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
  Setzung 2/3 **nicht** vereinbar, ohne die Konvention zu ändern. Dann blockiert der Slice an einer
  Architect-Entscheidung — er geht zurück und wartet auf sie, statt die Norm im
  Implementations-Kontext mitzunehmen.

## 5. Closure-Trigger

DoD (1) bis (3) erfüllt mit gefahrenen Kommandos, `make gates` grün (**mit** `planning` in der
Modul-Liste), `make mutate` ohne Befund, Review nach Modul 10 und Verifikation nach Modul 11 ohne
blockierenden Befund, Closure-Notiz in §7 mit Steering-Loop-Eintrag und der ausgewiesenen Übergabe
aus §3.

## 6. Risiken und offene Punkte

- **Der Prüfbereich dieses Gates ist die Roadmap — und die Roadmap ist ein Planner-Artefakt.** Ein
  Gate, das rot wird, weil der Planner eine Welle hebt, erzeugt Druck, die Roadmap dem Sensor
  anzupassen statt umgekehrt. Das ist nicht per se falsch (mechanische Konsistenz ist der Zweck),
  aber es muss **entschieden** sein und nicht als Nebenwirkung eintreten. Genau dafür ist DoD (2)
  eine Entscheidung und keine Konfiguration.
- **Die Versuchung, den Befund wegzukonfigurieren, ist hier größer als bei jedem anderen Slice der
  Welle.** `heading` und `marker` sind frei wählbar; eine Sektion, die den Marker nie trägt, macht
  die Invariante trivial wahr. Der Gate wäre dann grün, dauerhaft, und ohne Aussage — das
  Gegenteil dessen, wofür er adoptiert wird.
- **`wave-preview-exists` auf `welle-09` zeigt auf ein ungelöstes Prozess-Thema, nicht auf einen
  Tippfehler.** [welle-09](../welle-09-modul-15-konformitaet.md) liegt flach und hat nach
  Aktenlage drei nie geschnittene Mitglieder. Dieser Slice **entscheidet ihre Lage nicht** — er
  macht sie nur sichtbar, und wer das mit einer Ausnahme beantwortet, verdeckt sie wieder.
- **Diese Datei wandert selbst durch den Prüfbereich.** Der Slice liegt in `open/`, geht nach
  `in-progress/` und dann nach `done/`; währenddessen ändert er die Invariante, die über genau
  dieses Verzeichnis urteilt. Der Umsetzungs-Lauf muss den Gate also **in** dem Zustand grün
  bekommen, in dem er selbst `in-progress/` besetzt — nicht nur in dem, in dem er fertig ist.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Die
Planungs-Ablage ist die dichteste Sub-Area des Repos — Modul 5 setzt den Lifecycle, Modul 6 die
Roadmap-Struktur, und [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
die Abweichung dazwischen.
