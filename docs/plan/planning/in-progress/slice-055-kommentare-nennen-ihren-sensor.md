# Slice slice-055: Ein Kommentar nennt seinen Sensor oder behauptet nichts

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (reaktive Wartung — Nutzer-Befund; die drei
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)-Schnittfragen
antworten alle „nein": kein Bündel, kein gemeinsames Closure-Kriterium, reaktiver Auslöser).

**Bezug:** [`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel) —
der Slice trägt die Regel in den *computational-feedback*-Quadranten; [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein Gate behauptet keine Abdeckung, die es nicht hat — dieselbe Klasse eine Ebene tiefer);
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (der Sensor kommt mit `bash`+`awk` aus).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-27.

---

## 1. Ziel

Ein Kommentar, der eine **Abdeckung behauptet** („bewacht", „belegt", „garantiert", „verhindert"),
**nennt den Sensor**, der sie trägt — oder er behauptet sie nicht. Durchgesetzt von einem Gate,
nicht von Disziplin.

## 2. Definition of Done

- [x] **(1) Der Ist-Bestand ist geprüft und bereinigt.** Jede Abdeckungs-Behauptung in einem
  **echten** Code-Kommentar (Go außerhalb von Roh-String-Literalen; `harness/tools/*.sh`) nennt
  entweder ihren Sensor — Testname, `make`-Target, `full-smoke`, `test/mutations` — oder die
  Behauptung fällt weg. **Mindestens eine ist heute nachweislich falsch:**
  `internal/gen/gen.go:74` behauptet, der unerreichbare Zweig sei „über einen Renderer ohne
  hexslice bewacht" — einen solchen Renderer gibt es nicht. Beleg am Ende per Kommando, nicht
  per Durchsehen.
- [x] **(2) Ein Gate hält die Klasse.** Neues `make`-Target (bash+awk, hermetisch, in `gates`):
  es scannt echte Kommentare, meldet jede Behauptung ohne Sensor-Nennung und ist **fail-closed**.
  **Roh-String-Literale sind ausgenommen** — der emittierte Inhalt ist Anleitung an den Adopter,
  nicht unsere Zusage; ohne diese Trennung wäre das Gate sofort falsch-rot.
- [x] **(3) Der Sensor hat Zähne.** Ein Gegenbeispiel wurde **rot gesehen** (Behauptung ohne
  Sensor-Nennung → Gate rot) und liegt als `test/mutations/`-Fall vor; dazu bats-Tests für die
  Roh-String-Ausnahme ([`AGENTS.md`](../../../../AGENTS.md) §3.6, Präzedenz `start-smoke.sh`:
  Skript + Tests + Mutations-Fall).
- [x] `make gates` grün, `make mutate` ohne Befund.
- [x] Doku: die neue Gate-Zeile in [`AGENTS.md`](../../../../AGENTS.md) §4 und
  [`harness/README.md`](../../../../harness/README.md) — ein Gate, das dort fehlt, ist ein
  undokumentierter Vertrag.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-27, live — Kommando neben jeder Aussage):**

| # | Aussage | Kommando / Beleg |
|---|---|---|
| 1 | Regel-setzende Marker sind **nicht** das Problem | `grep -rn "^\s*//" internal/ cmd/ --include=*.go \| grep -v _test.go \| grep -cE "MUSS\|muss \|darf (nicht\|nie)\|NIE "` → **19** von 1815 Kommentar-Zeilen; durchgesehen sind sie beschreibend (erklären die Prüfung darunter, geben eine fremde Vorschrift wieder oder spiegeln eine verankerte Regel) |
| 2 | Behauptete **Abdeckung** ist das Problem | dasselbe Muster mit `garantiert\|stellt sicher\|bewacht\|belegt\|sorgt dafuer\|verhindert` → **14** in Go, **10** in `harness/tools/*.sh` |
| 3 | Mindestens eine Behauptung ist **falsch** | `sed -n '74p' internal/gen/gen.go` → „über einen Renderer ohne hexslice bewacht"; `grep -n "cpp\"\|go\"" internal/gen/gen.go` zeigt: beide Sprachen tragen beide Architekturen |
| 4 | Der Scanner braucht die Roh-String-Ausnahme | `grep -n "belegt" internal/gen/cpp.go` trifft Zeilen **innerhalb** emittierter C++-Konstanten — Adopter-Doku, nicht unsere Zusage |

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/comment-claims.sh` <!-- d-check:ignore (in diesem Slice erst angelegt) --> | neu | bash+awk-Scanner; Roh-String-Zustand über Backtick-Zählung, damit emittierter Inhalt ausgenommen bleibt |
| `Makefile` | update | `comment-claims`-Target, an `GATE_CHECKS`/`gates` gehängt |
| `internal/**/*.go`, `harness/tools/*.sh` | update | die 24 Behauptungen: Sensor nennen oder Behauptung streichen |
| `test/comment-claims.bats` <!-- d-check:ignore (in diesem Slice erst angelegt) --> | neu | Roh-String-Ausnahme + Positiv-/Negativ-Fall |
| `test/mutations/` | neu | ein Fall: Scanner entschärft → bats rot |
| [`AGENTS.md`](../../../../AGENTS.md), [`harness/README.md`](../../../../harness/README.md) | update | Gate-Tabelle (Hard Rule 3.1: kein undokumentiertes Gate) |

## 4. Trigger

**`open` → `in-progress`:** Nutzer-Befund vom 2026-07-27 („Kommentare sind nicht normativ"), im
selben Lauf durch eine reale Falschaussage belegt (slice-053 Review-F-1: der Kommentar behauptete
Lint-Abdeckung, die der Header-Filter verhinderte). Die Ist-Messung (§3) liegt vor.

Rückführungen:

- `in-progress` → `next`: falls die Bereinigung der 24 Fundstellen zeigt, dass „Sensor nennen" für
  eine ganze Gruppe nicht entscheidbar ist (etwa historische Prosa in `harness/tools/mutate.sh`) —
  dann trennt ein Re-Slice den Scanner vom Sweep.
- `in-progress` → `open`: falls der Scanner ohne Fehlalarm-Rate < 100 % nicht zu bauen ist (die
  Roh-String-Ausnahme trägt nicht) — dann ist es ein Carveout-Fall, kein Gate.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) — **ein Verdikt muss ausgestellt sein**; Verifikation
bestätigt die DoD (Modul 11); `make gates` und `make mutate` grün; Slice per `git mv` nach `done/`
(eigener Move-Commit, Link-Reconciliation im Folge-Commit); Closure-Notiz mit
Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Ein Wort-Grep ist der falsche Sensor für Semantik** — die Lehre aus slice-032: gegen erklärende
  Prosa schlug ein Wort-Grep fehl. Hier ist er tragbar, weil er **nicht** Bedeutung prüft, sondern
  eine **Form**: Behauptungs-Wort im Kommentar-Block ⇒ Sensor-Nennung im selben Block. Er kann eine
  *falsche* Sensor-Nennung nicht erkennen (ein erfundener Testname besteht ihn) — das bleibt
  Review-Arbeit und gehört benannt, nicht wegdefiniert.
- **Fehlalarm-Risiko bei historischer Prosa:** `harness/tools/mutate.sh` trägt einen langen
  Erklär-Kopf, `internal/emit/templates.go` Rückblicke im Präteritum („bewachte die
  Vollständigkeits-Achse"). Umformulieren statt Ausnahme-Liste — eine Ausnahme-Liste altert und
  wäre selbst wieder eine unbewachte Zusage.
- **Der Scanner darf nicht in emittierten Inhalt greifen.** Ohne Roh-String-Ausnahme wäre das Gate
  sofort falsch-rot (`internal/gen/cpp.go` trägt „belegt" in emittierten C++-Konstanten). Die
  Ausnahme ist die einzige nicht-triviale Stelle des Skripts und braucht eigene bats-Fälle.
- **Kein Carveout absehbar.** Bleibt eine Fundstelle unentscheidbar, wird die Behauptung gestrichen
  — das ist immer möglich und immer korrekt.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

**Was funktioniert hat.** Der Sweep ist belegt statt durchgesehen: `make comment-claims` meldet
**30 Datei(en), 0 Befund(e)**, und der Gate hängt in `gates` — die Klasse kann nicht
zurückdriften, ohne rot zu werden. `make mutate` **91 ok / 0** mit zwei neuen Fällen,
`make gates` Exit 0.

**Was anders lief als geplant — die Messung drehte den Zuschnitt.** Erwartet war „Modalverben
entschärfen". Gemessen: die 19 regel-setzenden Marker sind fast alle **beschreibend** (sie erklären
die Prüfung, die darunter steht, geben eine fremde Vorschrift wieder oder spiegeln eine verankerte
Regel). Das Problem war die **behauptete Abdeckung** — zehn Stellen, darunter eine am selben Tag
selbst erzeugte Falschaussage. Ein pauschaler Sweep über Modalverben hätte den Kontext vernichtet,
den das Repo bewusst pflegt, und das eigentliche Problem stehen gelassen.

**Steering-Loop-Eintrag: ein neu gebauter Sensor ist selbst eine Zusage — und zwar die
unbelegteste im Diff.** Vier Fehler entstanden **im Wächter**, nicht im bewachten Code:

1. Der Existenz-Check **bestätigte sich selbst** — er fand den erfundenen Testnamen in der
   Fixture, die ihn als Gegenbeispiel führt. (Verlangt jetzt die Definition, nicht die Erwähnung.)
2. `grep --include` gibt es im Alpine-basierten bats-Image nicht — der Gate war **im Container rot,
   lokal grün**. Dieselbe Klasse wie der EPIPE-Fall aus slice-039.
3. Ein bats-Fall **hatte keine Zähne**: die Fixture setzte die Behauptung auf die `const`-Zeile,
   die nie als Kommentar gelesen wird — die Ausnahme wurde nie ausgeübt. Gefunden von
   `make mutate`, nachdem `make test` grün gemeldet hatte.
4. Der Sweep selbst erfand zwei Sensor-Namen — der Anlass für Prüfung (b).

Verallgemeinert: **wer einen Sensor baut, hat den Sensor noch nicht.** Erst der rot gesehene
Mutations-Lauf macht aus dem Skript einen Wächter. Die Reihenfolge dieses Slice — grün gemeldet →
Mutation widerlegt → korrigiert → grün — ist der Beleg und wird hier festgehalten statt geglättet.

**Zweiter Eintrag, aus F-3 und F-1 zusammen:** ein Test, der die *Fixture* falsch baut, ist von
einem Test, der die Eigenschaft prüft, **im grünen Zustand nicht unterscheidbar**. Nur die Mutation
trennt sie. Das ist die operative Fassung von [`AGENTS.md`](../../../../AGENTS.md) §3.6 für
neu geschriebene Tests.

**Folge-Slices.** Keine neuen `open/`-Einträge. Zwei benannte Grenzen gehen in den Backlog:
der Prüfbereich lässt `test/**` aus (Review-F-6), und der Gate prüft Form statt Bedeutung — eine
korrekte, aber inhaltlich nicht tragende Sensor-Nennung besteht ihn (Review-F-5, per Konstruktion
Review-Arbeit).

## 8. Sub-Area-Modus-Begründung

**Alle berührten Sub-Areas GF** (siehe Kurs Modul 5 §Worked Mini-Example): die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) führt `*` (gesamtes Repo) und
`harness/tools/` als **Greenfield**. Der Vollblock entfällt damit laut Template.
