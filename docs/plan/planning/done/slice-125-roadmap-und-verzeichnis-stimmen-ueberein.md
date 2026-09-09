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
[slice-129](../done/slice-129-closure-notiz-hat-einen-sensor.md) geschnitten. **Beide Slices konfigurieren
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

- [x] **(1) `planning` ist in [`.d-check.yml`](../../../../.d-check.yml) aktiviert und läuft in
      `make gates` — über einer Invariante, die für dieses Repo wahr ist.**
      **Rot:** einen `slice-*.md` nach `in-progress/` legen, während die Roadmap-Sektion den
      Ruhe-Marker trägt (oder umgekehrt) → `make docs-check` fällt und nennt Datei, Zeile und
      `planning-drift`. Der unveränderte Baum bleibt grün. **Bleibt der unveränderte Baum nicht
      grün, ist DoD (2) nicht erledigt** — beide Läufe gehören in den Umsetzungs-Commit.
- [x] **(2) Die gewählte Sektion kann driften, und das ist vorgeführt — nicht behauptet.** Ein
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
- [x] **(3) Über die `waves`-Fähigkeit ist entschieden, und die zwei Befunde sind benannt.**
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

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau **einen** Ausgang aus
der geschlossenen Menge *eingetreten · entfallen · weiter offen*, und kein Slice geht nach `done/`,
während eines ohne Ausgang dasteht.

- **Der Prüfbereich dieses Gates ist die Roadmap — und die Roadmap ist ein Planner-Artefakt.** Ein
  Gate, das rot wird, weil der Planner eine Welle hebt, erzeugt Druck, die Roadmap dem Sensor
  anzupassen statt umgekehrt. Das ist nicht per se falsch (mechanische Konsistenz ist der Zweck),
  aber es muss **entschieden** sein und nicht als Nebenwirkung eintreten. Genau dafür ist DoD (2)
  eine Entscheidung und keine Konfiguration. — **Ausgang: entfallen.** Der befürchtete Druck hat
  keinen Mechanismus, und das ist gemessen statt angenommen: Die Invariante des Moduls bindet an
  **ein** Feld — den Ruhe-Marker gegen den Inhalt von [`in-progress/`](../in-progress) —, nicht an
  die Zeiger-Liste unter *Offene Wellen*. Eine gehobene Welle fügt der Liste eine Zeile hinzu und
  bewegt den Marker nicht; die Listen-Hälfte bleibt nach DoD (3) ausdrücklich unbewacht, weil
  `waves` aus ist (`grep -E '^  (waves|closure|observations):' .d-check.yml` → leer). Beide
  Richtungen des Markers hat der Verifikations-Lauf an Kopien außerhalb des Arbeitsbaums selbst
  gefahren. **Was der Gate wirklich verlangt**, ist die Rückstellung des Markers beim
  Lifecycle-Wechsel — das ist Risiko 4 und hat dort seinen eigenen Ausgang.
- **Die Versuchung, den Befund wegzukonfigurieren, ist hier größer als bei jedem anderen Slice der
  Welle.** `heading` und `marker` sind frei wählbar; eine Sektion, die den Marker nie trägt, macht
  die Invariante trivial wahr. Der Gate wäre dann grün, dauerhaft, und ohne Aussage — das
  Gegenteil dessen, wofür er adoptiert wird. — **Ausgang: entfallen, und zwar knapp.** Die
  gewählte Sektion nimmt beide Zustände an — der Verifier hat `planning-drift` in **beide**
  Richtungen selbst reproduziert, an isolierten Kopien mit demselben Digest wie `make docs-check`.
  Eingetreten ist nicht die falsche Konfiguration, sondern der **fehlende Wächter** darüber: Zwei
  Einzeländerungen (`marker:` gelöscht, so dass der stumme Modul-Default greift; `heading` auf eine
  marker-lose Sektion) ließen `docs-check` grün und entwerteten die Invariante — Review-Runde 1,
  HIGH. Seit der Nacharbeit trägt jede der beiden einen eigenen Fall (`271`, `272`), im
  `make mutate`-Vollauf einzeln bestätigt. Die Entwertung kann damit nicht mehr still geschehen;
  sie färbt den Fall-Satz rot. Der Fund selbst ist als Klasse gezählt (§7).
- **`wave-preview-exists` auf `welle-09` zeigt auf ein ungelöstes Prozess-Thema, nicht auf einen
  Tippfehler.** [welle-09](../welle-09-modul-15-konformitaet.md) liegt flach und hat nach
  Aktenlage drei nie geschnittene Mitglieder. Dieser Slice **entscheidet ihre Lage nicht** — er
  macht sie nur sichtbar, und wer das mit einer Ausnahme beantwortet, verdeckt sie wieder. —
  **Ausgang: entfallen.** Das Risiko hing an der Aktivierung von `waves`, und DoD (3) hat gegen
  sie entschieden, mit dem Grund in [`harness/README.md`](../../../../harness/README.md) neben
  dem, was `docs-check` **nicht** prüft. Ohne den `waves:`-Block erzeugt das Modul keinen der zwei
  Befunde; der Gate-Lauf dieser Closure meldet `0 Befund(e)` und keinen Grund-Code `wave-*`. **Was
  nicht entfällt und darum hier steht:** Die Lage von welle-09 ist dadurch weder entschieden noch
  sichtbarer geworden. Sie steht, wo sie stand — als Zeiger unter *Offene Wellen* und im Drift-Log
  der Roadmap (2026-08-28, *„bleibt offen und ruhend"*). Keine Ausnahme eingetragen, kein
  Folge-Slice geschnitten: Eine Ausnahme hätte sie verdeckt, wie dieser Absatz verlangt, und eine
  Kennung behauptete eine Datei, die es nicht gibt.
- **Diese Datei wandert selbst durch den Prüfbereich.** Der Slice liegt in `open/`, geht nach
  `in-progress/` und dann nach `done/`; währenddessen ändert er die Invariante, die über genau
  dieses Verzeichnis urteilt. Der Umsetzungs-Lauf muss den Gate also **in** dem Zustand grün
  bekommen, in dem er selbst `in-progress/` besetzt — nicht nur in dem, in dem er fertig ist. —
  **Ausgang: weiter offen → Beobachtungs-Register**
  ([`lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md),
  **1×**, neu). Die im Text benannte Hälfte ist erfüllt und nachgemessen: Der unveränderte Baum mit
  besetztem `in-progress/` bleibt grün. Die **symmetrische** Hälfte hat der Text nicht benannt —
  der `git mv` dieser Closure leert `in-progress/` und macht den Marker falsch, und die Pflicht,
  ihn zurückzustellen, stand in keinem Artefakt, das die Closure liest: §6 nur für die
  Umsetzungszeit, §7 leer, die Übergabe-Liste des freigebenden Review-Laufs ohne sie, und
  `make slice-mv` zieht nach eigener Zusage *Pfade nach, keine Zustandssätze*. Diese Closure führt
  den Schritt aus (eigener Commit nach dem Move); die **Lücke** schließt sie nicht — keine Quelle
  schreibt den Ausgleichs-Schritt vor. Kein Folge-Slice: Der Eintrag hängt am Zähler und wird beim
  dritten Auftreten von selbst fällig.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennungen **zitieren** statt neu zu formulieren — sonst
zählt das Register zwei Namen getrennt) · `grundlagen-traceability.md` §Herkunfts-Anker für
Steering-Loop-Regeln (das Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas
verkörpert wurde).

**Rolle:** Planner (Baseline-Regelwerk `modul-05-planning-harness.md` §Closure- und
Lerneintrag-Regeln, [`AGENTS.md`](../../../../AGENTS.md) §3.10 — frischer Kontext, eigener Commit).
**Datum:** 2026-09-06. **Gegenstand:** die Commit-Kette von `c63ef63` (Umsetzung) bis `2c96074`
(Verifikation), zwölf Umsetzungs- und Nacharbeits-Commits über elf Dateien, dazu drei
Review-Runden und ein Verifikations-Lauf. Jede Zahl unten ist **in diesem Lauf** erhoben; die
Zahlen aus Planung, Umsetzung, Review und Verifikation waren Eingabe, kein Beleg
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1).

- **Was hat funktioniert: die DoD hat ihre eigene Ausweichbewegung vorweggenommen.** DoD (2) hat
  das Abnahme-Kriterium nicht auf *„der Befund ist weg"* gelegt, sondern auf *„die Invariante kann
  in der gewählten Sektion überhaupt driften"* — mit dem ausdrücklichen Rot-Fall, dass die
  Auflösung darin bestünde, `heading` auf eine Sektion zu zeigen, in der nichts driften kann. Genau
  diese Prüfung hat der Verifier gefahren, in **beide** Richtungen und an isolierten Kopien; ohne
  die Form von DoD (2) wäre ein grüner Gate über einer trivial wahren Invariante ein bestandener
  Slice gewesen. Der Slice ist damit die Antwort auf seinen eigenen Anlass: Ein Modul stand in
  `modules:` und prüfte nichts, weil ihm der Config-Block fehlte
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) —
  und der naheliegende Weg, es „zu aktivieren", hätte denselben Zustand mit mehr Konfiguration
  erzeugt.
- **Was ging anders als geplant — die Aktivierung eines siebten Moduls war ein Ein-Zeilen-Diff mit
  einem elfstelligen Nachhall.** Der Kern des Slice (`planning` in `modules:`, der `planning:`-Block
  mit `roadmap`/`heading`/`marker`) ist klein und hat vom ersten Umsetzungs-Commit an gehalten;
  keine der drei Review-Runden hat ihn angegriffen. Teuer waren die **Aussagen daneben**: Die
  Modul-Liste ist Operand von Prosa in **zwölf** lebenden Artefakten, und der Diff hat sie alle
  falsch gemacht. Dazu kam eine Verhaltensänderung an einer Stelle, die niemand als betroffen erwartet
  hatte — `make regelwerk-check` ist der einzige d-check-Aufruf dieses Repos, der die Modul-Liste
  **aufzählt**, statt erschöpfend zu disablen, und fuhr nach der Aktivierung ein zweites Modul mit
  (Review-Runde 2, HIGH). Drei Runden Nacharbeit gingen fast vollständig auf diese Klasse; die
  Implementation selbst wurde einmal berührt.
- **Was der Review beitrug** (dritte Quelle nach Baseline-Regelwerk `modul-05-planning-harness.md`
  §Closure- und Lerneintrag-Regeln): drei Runden, vierzehn Findings.
  [Runde 1](../../../reviews/2026-09-06-slice-125-planning-modul-review.md) — 1 HIGH, 4 MEDIUM,
  1 LOW, 2 INFO, blockierend; der HIGH traf genau die Stelle, an der der Slice sein eigenes Ziel
  verfehlt hätte (Zahn auf dem lauten statt auf den zwei stillen Pfaden).
  [Runde 2](../../../reviews/2026-09-06-slice-125-re-check-nacharbeit.md) — alle fünf angegangenen
  behoben, sechs neue, darunter der `regelwerk-check`-HIGH mit **geändertem Verhalten**.
  [Runde 3](../../../reviews/2026-09-06-slice-125-re-check-runde-3.md) — kein HIGH, für den
  Verifier freigegeben; ihr einziger MEDIUM (R-1) misst nach, dass die Fundmengen-Messung des
  Implementers **einen** Treffer meldete, wo **elf** lebende Stellen standen — neun davon in keiner
  Runde benannt —, und benennt die zwei Methodenfehler, die eine von ihnen auch der Messung selbst
  entzogen haben. Dieser MEDIUM ist der Grund, warum diese
  Closure zwei Übergaben schreibt statt einer. **Und die Kette geht eine Runde weiter:** Diese
  Closure hat R-1s Fundmenge nicht übernommen, sondern über einem breiteren Muster neu gefahren —
  und **zwei** weitere Fundstellen gefunden, die auch Runde 3 nicht hatte (unten, Übergabe 2). Die
  Klasse hat damit in **einem** Vorgang drei Messungen überlebt, jede breiter als die vorige.
- **Was diese Closure nicht deckt — drei Posten, benannt statt still:**
  **(1) Der Lese-Schritt des Beobachtungs-Registers gehört nicht hierher.** Dieses Repo führt
  Wellen-Betrieb (`ls docs/plan/planning/welle-*.md` nennt drei offene Welle-Dateien), und
  *wellenlos* ist nach Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht
  eine Eigenschaft des **Repos**, nicht des einzelnen Slice. Diese Closure zählt und weist
  Risiko-Ausgänge zu; sie liest keine Schwellen. **Ein Eintrag ist damit fällig geworden** — siehe
  Register unten.
  **(2) Die drei Paarungen laufen bei der Welle-Closure.** `slice-125` gehört zu
  [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md). Vorgearbeitet ist die Register-Paarung
  insoweit, als jede unten genannte Beobachtung als Verzeichnis existiert und jede mindestens einen
  Beleg trägt.
  **(3) Neun der elf Planner-eigenen Prosa-Stellen sind nachgezogen, aber ohne Wächter.** Kein
  Modul aus `modules:` urteilt über den Wahrheitsgehalt einer Prosa-Zahl, und `make comment-claims`
  hat keine Markdown-Datei im Prüfbereich. Die nächste Änderung an `modules:` erzeugt dieselbe
  Fundmenge neu.
- **Steering-Loop-Eintrag — geschärfte Regel:** *Wer einen Sensor über ein Feld des eigenen
  Prozesses legt, benennt in §6 den **Lifecycle-Schritt**, an dem der Sensor gegen den Prozess
  läuft — nicht nur den Zustand, in dem er grün sein muss.* Dieser Slice hat die eine Hälfte
  benannt (*„der Gate muss grün sein, während `in-progress/` besetzt ist"*) und die
  symmetrische übersehen: Sein eigener `git mv` nach `done/` leert `in-progress/` und macht den
  Ruhe-Marker falsch — **der Slice fängt seine eigene Closure**. Bemerkt hat es der Verifier, weil
  er den Rot-Fall in beide Richtungen selbst nachstellte; benannt war die Pflicht in Review-Runde 1
  und aus der Übergabe-Liste von Runde 3 wieder herausgefallen. Getragen hat sie am Ende allein der
  Stop-Hook, der vor Session-Ende einen frischen grünen `make gates`-Lauf verlangt — mechanisch,
  nicht vorgeschrieben. *Gezählt, nicht verkörpert:* Die Regel ist hier formuliert, nicht
  geschrieben; ihr Zielort wäre ein Anweisungssatz oder eine Hard Rule, und über deren Form
  entscheidet nicht diese Closure. Das Feld `liegt in` entfällt darum. Auslöser:
  [`lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  (**1×**, neu) — die dritte Hälfte einer Familie, deren zwei andere bereits `verkörpert` sind
  ([`verweise-brechen-beim-ortswechsel`](../observations/BEO-ALL/verweise-brechen-beim-ortswechsel/observation.md)
  für die Verweise,
  [`vorgeschriebener-ortswechsel-macht-adresse-tot`](../observations/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/observation.md)
  für die Adresse).
- **Beobachtungs-Register: acht Belege, davon fünf in neuen Verzeichnissen.** Jeder Zähler ist die
  Zahl der Dateien unter `evidence/`
  (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`) — **keine
  Erwartungswerte**, sie wandern mit dem Register. **Ein Vorgang zählt einmal:** Die drei
  Review-Runden und der Verifikations-Lauf sind derselbe Vorgang `slice-125`, und mehrere Funde
  derselben Klasse darin sind **eine** Gelegenheit.
  [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  **16×** — **ein** Beleg für **sieben** Funde (F-3, F-4, N-1, N-4, N-5, R-2, R-4), nicht sieben ·
  [`uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md)
  **2×** (F-5, dazu N-2 als zweiter Fund derselben Familie) ·
  [`zitat-grep-uebersieht-zeilenumbruch-und-markup`](../observations/BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup/observation.md)
  **3×** (die Methoden-Hälfte von R-1) — **damit an der Schwelle**, siehe Übergabe 3 ·
  [`mutations-fall-deckt-den-lauten-statt-den-stillen-pfad`](../observations/BEO-ALL/mutations-fall-deckt-den-lauten-statt-den-stillen-pfad/observation.md)
  **1×**, neu (F-1 und R-3) ·
  [`zusicherung-ueber-der-leeren-menge-wahr`](../observations/BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr/observation.md)
  **1×**, neu (F-8 und N-3) ·
  [`aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/observation.md)
  **1×**, neu (F-2 und F-6) ·
  [`lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  **1×**, neu (Verifikations-Bericht §5, §6 Risiko 4) ·
  [`messung-nimmt-lebendes-register-in-den-eingefrorenen-ausschluss`](../observations/BEO-ALL/messung-nimmt-lebendes-register-in-den-eingefrorenen-ausschluss/observation.md)
  **1×**, neu (die Ausschluss-Hälfte von R-1).
  **Zwei Finding-Klassen bekommen ausdrücklich keinen Eintrag, und hier steht warum.** F-7 (die
  Plan-Übergabe zeigt auf einen zurückgebauten
  [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)-Rumpf)
  ist derselbe Mechanismus wie *Zusage neben geänderter Ableitung* — eine Aussage bleibt stehen,
  während ihre Grundlage sich bewegte — und ist mit deren Beleg für diesen Vorgang bereits gezählt.
  N-6 (die Commit-Message begründet mit einer nicht gemessenen Unmöglichkeit) trifft eine Regel,
  die **schon steht**:
  [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  nimmt die Commit-Message dieses Repos ausdrücklich in den Geltungsbereich der Beleg-Disziplin.
  Das Register zählt fehlende Regeln, nicht Verstöße gegen stehende.

### Übergabe 1 — an den Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8): drei Stellen, keine hier angefasst

Der Hard-Rule-Block, der Adaptions-Block und der ADR-Index sind Architect-Eigentum; diese Closure
liefert **Messungen**, keinen Norm- und keinen Index-Text.

1. **[`AGENTS.md`](../../../../AGENTS.md) §3.8 nennt die Modul-Liste als Sechser-Liste**, während
   `grep -m1 '^modules:' .d-check.yml` sieben führt. Von diesem Slice verursacht.
2. **`docs/plan/adr/README.md` nennt sie ebenfalls** — und diese Stelle ist in **keiner** der drei
   Review-Runden zuvor benannt worden. Sie fiel durch zwei Methodenfehler zugleich: Der Ausschluss
   `docs/plan/adr/**` behandelt den **Index** wie eine eingefrorene ADR
   ([`AGENTS.md`](../../../../AGENTS.md) §3.4), obwohl er ein lebendes, nach
   [`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) dem
   Architect gehörendes Register ist; und die Aufzählung bricht nach `codepaths,` um, so dass ein
   zeilenweiser `grep` sie nicht trifft. Beide Klassen sind unten gezählt.
3. **Die Modus-Deklaration in
   [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
   beziffert die Verzeichnisse des Registers**, und diese Closure bewegt die Zahl: Sie legt fünf
   neue an, `ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` gibt danach **62** aus.
   Der Eintrag war schon vor diesem Slice hinter dem Bestand — die Zahl ist als datierte Messung
   geführt und kein Erwartungswert, aber sie steht jetzt weiter daneben. **Kein Fund dieses
   Slice**, sondern ein Nachzug, den nur der Architect schreiben darf.

### Übergabe 2 — im Planner-Eigentum, hier entschieden und ausgeführt

**Die Fundmenge ist hier neu gefahren statt übernommen, und sie ist größer als in R-1:
dreizehn Fundstellen in zwölf Dateien.** Zwei Siebe braucht es dafür, und **dass sie zusammen
nicht reichen, ist der Befund und keine Umständlichkeit** — die Aussage steht im Bestand in zwei
Formen, als Literal-Liste und als Zahlwort, und ein Zahlwort ist nur dann greifbar, wenn *Modul*
in derselben Zeile steht:

```sh
R=b0fbde7   # der Stand vor diesem Nachzug; ohne Operand zaehlte das Kommando sein eigenes Zitat mit
git grep -nE 'links, anchors, ids, matrix, codepaths, spans([^,]|$)' $R -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' ':!docs/plan/planning/observations' ':!harness/conventions' ':!docs/plan/adr/0*' | wc -l                        # 5
git grep -nE '\b[Ss]echs\b' $R -- 'docs/plan/planning/open' 'docs/plan/planning/in-progress' 'docs/plan/planning/welle-*.md' | grep -i modul | grep -vcE 'Modul [0-9]|modul-[0-9]'   # 11
```

**Die zwei Siebe liefern 16 Zeilen und finden damit 11 der 13** — abzuziehen sind eine
Überschneidung (`slice-121` über zwei Zeilen) und vier Zeilen, die die Modul-Liste nicht meinen
(ein Mutations-Fall, eine Spec-Tabelle, eine DoD-Punkte-Zählung und die geprüfte Nicht-Fundstelle
unten).
**Zwei findet keines von beiden, und beide zeigen dieselbe Schwäche:**
`docs/plan/adr/README.md:83-84` bricht die Aufzählung nach `codepaths,` um (Sieb 1 verfehlt sie),
und `welle-13` §6 schreibt *„aktiviert **sechs**"* ohne das Wort *Modul* in derselben Zeile
(Sieb 2 verfehlt sie). Gefunden sind beide durch **Lesen**, nicht durch ein Muster — genau die
Grenze, die
[`zitat-grep-uebersieht-zeilenumbruch-und-markup`](../observations/BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup/observation.md)
führt.

**Zwei der dreizehn gehören dem Architect** (oben, Übergabe 1). **Elf gehören dem Planner**, und
**neun sind gezogen** statt vertagt: der Arbeitspunkt selbst in
[`roadmap.md`](../in-progress/roadmap.md) (N-4 — die Zeile, die die Klasse beschreibt, trug sie),
die Modul-Zählung in [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) §6 und sieben
Slice-Pläne in [`open/`](../open) (`slice-073`, `slice-116`, `slice-121`, `slice-124`, `slice-127`,
`slice-129`, `slice-139`). Die Alternative wäre gewesen, sie an den Arbeitspunkt
*(6) Prosa-Aufzählung gegen ihre Config* des Roadmap-Kandidaten *Doku- und Sensor-Wartung* zu
hängen; dagegen sprechen zwei Gründe: Es sind Ein-Wort-Änderungen, und der Kandidat ist nicht
geschnitten — eine Kennung dort wäre ein verbuchter Ausgang ohne Datum. **In einem eigenen
Commit**, nicht in dem der Closure: Ein Prosa-Nachzug in neun Planner-Artefakten ist kein
Closure-Artefakt nach [`AGENTS.md`](../../../../AGENTS.md) §3.10.

**Zwei Fundstellen bleiben bewusst stehen, und hier steht warum.** Beide liegen in
[slice-135](../open/slice-135-d-check-pin-v0661.md), und beide sind Teil einer **datierten Messung**
über die Spanne `v0.65.0..v0.66.1` — einer Spanne, die das Repo mit
[slice-187](../done/slice-187-d-check-pin-v0741.md) hinter sich gelassen hat. Der Plan ist als
überholt geführt
([`ueberholter-offener-plan-ohne-genormten-ausgang`](../observations/BEO-ALL/ueberholter-offener-plan-ohne-genormten-ausgang/observation.md)).
Eine Zahl darin zu ziehen hieße, eine überholte Messung als aktuell auszugeben — teurer als der
sichtbare Fehler.

**Eine dritte Stelle ist geprüft und **kein** Fund:** `welle-13` §1 Punkt 3 sagt, der
Pin-Trockenlauf von `slice-187` habe *„die sechs aktiven Module"* gefahren. Das ist über jenen Lauf
wahr — er lag vor dieser Aktivierung. Geändert ist allein die Zeitform, damit die Zahl nicht als
heutiger Stand gelesen wird.

### Übergabe 3 — an die Closure von [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md)

[`zitat-grep-uebersieht-zeilenumbruch-und-markup`](../observations/BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup/observation.md)
steht mit dem Beleg dieses Slice bei **3×** und ist damit fällig. Der Lese-Schritt gehört im
Wellen-Betrieb der Welle-Closure; `state.md` trägt bis dahin weiter `offen` — zulässig und
vorübergehend (Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register). Der Eintrag
braucht dort einen der drei Ausgänge.

### Die Entscheidung vor dem Move ([`AGENTS.md`](../../../../AGENTS.md) §3.11, [`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 4)

Gemessen über **beide** Adress-Formen am eingefrorenen Stand vor dieser Notiz — der Baum-Operand
hält die Zahl fest, ohne ihn zählte das Kommando sein eigenes Zitat mit:

```sh
R=2c96074; F=slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md
git grep -n -F "$F" $R -- ':!.harness/baseline'           | wc -l   # 27  Fundstellen
git grep -l -F "$F" $R -- ':!.harness/baseline'           | wc -l   # 15  Dateien
git grep -n -F "$F" $R -- 'docs/plan/planning/done'       | wc -l   # 11  in done/
git grep -n -F "$F" $R -- 'docs/reviews'                  | wc -l   #  6  in Rollen-Reports
git grep -l -F "$F" $R -- ':!.harness/baseline' ':!*.md'  | wc -l   #  0  Code-Span-Achse
```

**17 der 27 Fundstellen liegen in einfrierenden Artefakten** — elf in acht Dateien unter
[`done/`](../done), sechs in zwei Rollen-Reports. Die Code-Span-Achse ist leer: Kein Nicht-Markdown
nennt diese Datei. Genau eine Fundstelle trägt kein Verzeichnis-Literal und bleibt von der
Eingehend-Ersetzung unberührt — die nackte Zeile in einer zitierten `ls`-Ausgabe im
Verifikations-Bericht; sie ist ein Such-Literal und kein Link, `make docs-check` sieht sie nicht.

**Entschieden: der Nachzug läuft, das Ventil nicht** — dieselbe Entscheidung wie bei
[slice-123](../done/slice-123-ci-sieht-die-historie.md), aus denselben drei Gründen und hier neu
gehalten. **(1)** Ein fünftes namentlich geschnittenes `ignore-refs`-Paar ist nach
[`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 2 eine
neue Senkung mit eigener ADR ([`AGENTS.md`](../../../../AGENTS.md) §3.5) — ein zu hoher Preis für
eine Adresse, die nach dem Nachzug wieder auflöst. **(2)** Den Verweis brechen zu lassen ist keine
Option: `make docs-check` würde rot, und ein rotes Gate ohne Carveout schließt keinen Slice.
**(3)** Der Nachzug in [`docs/reviews/`](../../../reviews) ist die **entschiedene** Bauart dieses
Repos und keine Umgehung — [`harness/README.md`](../../../../harness/README.md) §Sensors führt aus,
dass `docs/reviews/**` von der Eingehend-Ersetzung ausdrücklich nicht ausgenommen ist, weil seine
Verweise reale, von `docs-check` geprüfte Links sind. Geändert wird die **Adresse**, nicht die
**Aussage** des Reports. **Was offen bleibt, ist dieselbe Norm-Frage wie damals:** Ob eine
mechanische Adress-Ersetzung eine *Berührung* im Sinne des Einfrierens ist, sagt keine Quelle über
Rang 9. Sie ist bei [slice-123](../done/slice-123-ci-sieht-die-historie.md) als Übergabe an den
Architect gestellt worden und hier nicht neu entschieden.

- **Folge-Slices: keine geschnitten**, und das ist eine Entscheidung. Zwei der vier Risiken sind
  entfallen, eines mit einer Messung, eines mit einer Konfigurationsentscheidung; das vierte hängt
  am Zähler und wird beim dritten Auftreten von selbst fällig.
  [slice-129](../done/slice-129-closure-notiz-hat-einen-sensor.md) bleibt liegen — er konfiguriert
  denselben Schlüsselbaum und war schon vor diesem Slice geschnitten; die `waves`-Aktivierung
  bekommt hier **keine** Kennung, weil sie eine Datei behauptete, die es nicht gibt
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Risiken aus §6:** vier, je genau ein Ausgang — **drei entfallen** (Roadmap-Druck ohne
  Mechanismus · Wegkonfigurieren durch zwei neue Fälle laut gemacht · `wave-preview-exists` ohne
  Aktivierung gegenstandslos), **eines weiter offen → Register**
  ([`lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)).
  Kein *eingetreten*, also kein Carveout und kein Folge-Slice aus dieser Quelle.
- **Verifikation, und was sie deckt:** Die drei DoD-Punkte sind vom
  [Verifier](../../../reviews/2026-09-06-slice-125-planning-modul-verify.md) einzeln nachgemessen
  worden — beide Rot-Richtungen an isolierten Kopien außerhalb des Arbeitsbaums, netzlos, mit dem
  Digest aus [`d-check.mk`](../../../../d-check.mk) —, dazu `make gates` EXIT 0 und
  `make mutate` als Vollauf mit **259 ok, 0 Befund(e)**, alle fünf slice-eigenen Fälle
  (`269`–`273`) einzeln bestätigt. **In diesem Closure-Lauf** ist `make gates` nach allen
  Änderungen dieser Closure erneut gefahren, EXIT 0 — der Beleg dafür, dass die
  Marker-Rückstellung nach dem `git mv` sitzt. **Was `make gates` nicht deckt:** `make mutate` ist
  hier nicht erneut gefahren — diese Closure ändert keine Datei in seinem Prüfgegenstand;
  `make smoke`/`make full-smoke` brauchen Netz und stehen außerhalb.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Die
Planungs-Ablage ist die dichteste Sub-Area des Repos — Modul 5 setzt den Lifecycle, Modul 6 die
Roadmap-Struktur, und [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
die Abweichung dazwischen.
