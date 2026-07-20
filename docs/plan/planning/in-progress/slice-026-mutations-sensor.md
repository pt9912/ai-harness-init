# Slice slice-026: Mutations-Sensor für Hard Rule 3.6 (`make mutate`)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Wartung) — wie slice-015…021. Einordnung
*(Kontext, nicht normativ)*: [roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids), [`AGENTS.md`](../../../../AGENTS.md) §3.6.

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-20.

---

## 1. Ziel

> **Herkunft: eine Hard Rule mit nur einem Quadranten.** [`AGENTS.md`](../../../../AGENTS.md) §3.6
> („keine Zusage ohne rot gesehenes Gegenbeispiel") entstand am 2026-07-20 aus neun
> Instanzen derselben Befund-Klasse in zwei Slices. Sie hat **kein computational
> feedback** — anders als 3.1–3.5, die je an einem Gate hängen. Modul 9 ist dazu
> eindeutig: *„Jede Hard Rule liegt in zwei Quadranten … Hard Rule nur in einem
> Quadranten ist halb durchgesetzt"* und *„Erst mit Fitness Function ist sie
> durchgesetzt. **Beides ist Pflicht.**"* Der Beleg kam prompt: **N-1** des
> 022b-Re-Reviews ist eine Instanz der Klasse, entstanden **nach** dem Formulieren
> von 3.6 und von `make gates` (EXIT=0) nicht bemerkt.

`make mutate` als **Nicht-Gate-Sensor**: ein kuratiertes Set aus *(Mutation →
erwartet rot färbender Test)*. Jede Mutation wird angewandt, `make test` gefahren,
ein **roter** Lauf erwartet und die Quelle zurückgesetzt. Färbt eine Mutation
**nicht** rot, hat der zugehörige Wächter seine Zähne verloren — und `make mutate`
schlägt an. Dazu der fehlende Feedforward-Haken in der Pre-completion-Checkliste.

## 2. Definition of Done

- [ ] `make mutate` existiert und fährt den Startbestand: die **sechs Proben**, die in der 022a/022b-Sitzung von Hand gefahren wurden (Pin-Kopplung, Sortier-Achse, Symlink-Achse, `inScope`, Fixture-Drift, toter Leer-Guard) — je mit **namentlich** erwartetem rot färbendem Test.
- [ ] **Der Sensor hat selbst Zähne** (Selbstanwendung von §3.6): eine Mutation, die den erwarteten Test **nicht** rot färbt, lässt `make mutate` rot werden — rot gesehen, nicht behauptet. Das ist der Kern: der Sensor misst die **Abwesenheit** von Rot, und genau das ist die Stelle, an der er selbst still grün werden könnte.
- [ ] [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): `make mutate` ist **nicht** in `make gates` (jede Mutation kostet einen vollen Docker-`test`-Zyklus) und steht als **Nicht-Gate-Verify** in [`AGENTS.md`](../../../../AGENTS.md) §4 und [`harness/README.md`](../../../../harness/README.md) §Sensors — dieselbe Zeile wie `make smoke`. Kein behaupteter Gate.
- [ ] **Die Grenze ist dokumentiert, nicht überdehnt:** der Sensor prüft die **Haltbarkeit** vorhandener Zähne, nicht die **Entstehung** neuer. Er fängt „ein Wächter hat Zähne verloren", nicht „eine neue Zusage wurde ohne Zähne geschrieben". Wer das nicht hinschreibt, begeht §3.6 am Sensor selbst.
- [ ] **Feedforward-Hälfte:** `.claude/commands/implement-slice.md` Schritt 18 verlangt neben dem grünen Gate-Lauf die Angabe, **welche Mutation welchen Sensor rot färbt**. Heute verlangt er nur „Sensor-Belege (`make gates`-Ausgabe)", also den grünen Lauf — genau die Lücke aus Befund N-6.
- [ ] [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten): bash + coreutils, kein neues Werkzeug; die Mutationen laufen über die vorhandenen `make`-Targets.
- [ ] **Mitgenommen aus dem 022b-Re-Review:** N-3 (der `emit.Templates`-Aufruf in `run()` ist von keinem Test beobachtet) und N-4 (`checkRoot` hängt an *einem* hart verdrahteten Dateinamen) — beide berühren dieselbe Fläche.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/mutate.sh` <!-- d-check:ignore (geplanter Pfad, Doc führt Code) --> | neu | Treiber: Quelle beiseite → Mutation → `make test` → **rot erwarten** → zurücksetzen. Fail-closed: ein grüner Lauf ist der Befund |
| `test/mutations/` | neu | Das kuratierte Set als Daten (Mutation + erwarteter Test), nicht als Code — damit ein neuer Wächter eine Zeile kostet, keine Funktion |
| `Makefile` | update | `mutate`-Target, **nicht** in `gates` |
| [`AGENTS.md`](../../../../AGENTS.md), [`harness/README.md`](../../../../harness/README.md) | update | Nicht-Gate-Verify-Zeile neben `make smoke`; §3.6 bekommt den Verweis auf ihr Feedback |
| `.claude/commands/implement-slice.md` | update | Schritt-18-Haken (Feedforward-Hälfte von N-6) |
| `cmd/ai-harness-init`, `internal/emit` | update | N-3 (Test auf die `run()`-Verdrahtung) und N-4 (robusterer Wurzel-Anker) |

## 4. Trigger

slice-022b in `done/`. Als Harness-Wartung hängt der Slice an keiner Welle —
die Roadmap sequenziert ihn (Modul 6: sie ist die Sequenzierungs-Autorität).

**Er sollte vor den verbleibenden welle-02-Slices landen** (025, 023, 004b). Nicht
weil er sie technisch blockiert, sondern weil die Befund-Klasse in **jedem** Slice
dieses Zuges auftrat: je früher der Sensor steht, desto mehr fängt er. Das ist eine
Empfehlung mit Begründung, keine Abhängigkeit — er wird nicht Mitglied von welle-02,
deren Ziel der Distributions-Umbau ist.

Rückführungen: `in-progress → next`, wenn Treiber und Mutations-Set nicht in eine
Sitzung passen (dann den Treiber mit **einer** Mutation, das Set als Folge-Slice).
`in-progress → open`, wenn sich zeigt, dass die Mutationen nicht stabil
anwendbar sind (dann ist die Datenform falsch gewählt — s. §6).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`. Damit ist
[`AGENTS.md`](../../../../AGENTS.md) §3.6 zweiquadrantig.

## 6. Risiken und offene Punkte

- **Der Sensor kann selbst still grün werden** — und das ist das Kernrisiko, weil er
  die *Abwesenheit* von Rot misst. Bricht der Treiber (Mutation greift nicht mehr,
  Patch veraltet, `make test` scheitert aus anderem Grund), sieht „kein Rot" wie
  „Zähne intakt" aus. Er muss **fail-closed** sein: greift eine Mutation nicht
  nachweisbar, ist das ein Befund, kein Übersprung. Ohne diese Setzung baut der
  Slice genau das, wogegen er gerichtet ist.
- **Mutationen sind Patches und veralten.** Wandert der mutierte Code, greift die
  Mutation ins Leere. Darum als **Daten** mit benanntem Ziel-Symbol statt als
  Zeilennummern-Patch — und der vorige Punkt macht das Veralten sichtbar.
- **Kuratiert heißt unvollständig.** Das Set deckt die Invarianten ab, die jemand
  aufgeschrieben hat. Ein neuer Wächter ohne Mutation ist unbewacht. Das ist
  akzeptiert (3.1s Gate deckt auch nur die *behaupteten* Targets), gehört aber in
  die Doku statt in die stille Annahme.
- **Laufzeit:** jede Mutation ist ein voller Docker-`test`-Zyklus. Sechs Proben sind
  vertretbar, sechzig nicht. Wächst das Set, ist die Tier-Frage neu zu stellen.
- **Selbstbezug beim Review:** dieser Slice wird von denselben Rollen geprüft, deren
  Befunde ihn ausgelöst haben. Der Reviewer sollte den Sensor gegen sich selbst
  wenden — eine Mutation am Treiber, die unbemerkt bliebe, wäre der aussagekräftigste
  Befund.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example);
`harness/tools/` ist im Adaptions-Block als GF geführt.
