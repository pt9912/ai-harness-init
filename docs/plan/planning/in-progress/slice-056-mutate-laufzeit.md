# Slice slice-056: Ein Mutations-Fall fährt nur den Sensor, den er braucht

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (reaktive Wartung — Nutzer-Beobachtung „mutate braucht über 15 Minuten"; die
drei [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)-Schnittfragen
antworten alle „nein": kein Bündel, kein gemeinsames Closure-Kriterium, **reaktiver** Auslöser).

**Bezug:** [`AGENTS.md`](../../../../AGENTS.md) §3.6 (`make mutate` ist der Sensor zu dieser Regel —
seine Aussage darf sich durch diesen Slice **nicht** ändern),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
schnellerer Lauf, der weniger prüft, wäre ein stilles Grün),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (bash + docker, kein
neues Werkzeug).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-27.

---

## 1. Ziel

`make mutate` fährt je Fall **nur den Sensor, dessen Rot er erwartet** — statt wie heute für jeden
der 92 Fälle beide zu bezahlen. Die **Aussage** des Laufs bleibt unverändert; nur die Kosten fallen.

## 2. Definition of Done

- [ ] **(1) Die Sensor-Wahl je Fall ist mechanisch und fail-closed.** Die vorhandene
  `# expect:`-Zeile bestimmt, welcher Sensor läuft: nennt sie einen Go-Test (`^Test[A-Z]`), fährt der
  Fall nur die Go-Stufe; sonst nur den bats-Container. **Bei Zweifel der volle Satz** — eine
  unbekannte, leere oder mehrdeutige `expect`-Zeile fährt **beide** Sensoren, nie weniger. Die
  bestehenden `# verify:`-Modi (`smoke`, `ci-lint`) bleiben unberührt.
- [ ] **(2) Die Aussage des Laufs ist nachweislich unverändert.** `make mutate` meldet weiterhin
  **92 ok / 0 Befunde**, und **jeder** Fall färbt weiterhin denselben Wächter rot wie vorher —
  belegt durch den Lauf, nicht durch Argumentation. Ein Fall, dessen Sensor **falsch** zugeordnet
  wird, muss auffallen: rot gesehen an einem absichtlich fehl-zugeordneten Fall.
- [ ] **(3) Vorher/Nachher ist gemessen, nicht geschätzt.** Laufzeit des vollständigen
  `make mutate` vor und nach dem Umbau, beide Zahlen in der Closure-Notiz. Bleibt der Gewinn unter
  einem Drittel, ist das ein Befund und gehört genannt — nicht weggelassen.
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update: die `mutate`-Beschreibung in [`AGENTS.md`](../../../../AGENTS.md) §4 und
  [`harness/README.md`](../../../../harness/README.md) sagt, dass je Fall nur ein Sensor läuft.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-27, live — Kommando neben jeder Zahl):**

| # | Aussage | Kommando / Beleg |
|---|---|---|
| 1 | **92 Fälle**, strikt sequenziell | `ls test/mutations/*.sh \| wc -l`; die Schleife in `harness/tools/mutate.sh` ist ein einfaches `for` ohne `&`/`xargs -P` |
| 2 | Jeder Fall zahlt **beide** Sensoren | `sed -n '/^test:/,+2p' Makefile` → `docker run … bats test/` **und** `docker build --no-cache-filter test --target test` |
| 3 | **60** Fälle erwarten einen Go-Test, **32** etwas anderes | `sed -n 's/^# expect: //p' test/mutations/*.sh \| grep -cE "^Test[A-Z]"` bzw. `-cvE` |
| 4 | **Kein** Fall ist ohne `expect`-Zeile | `grep -L "^# expect:" test/mutations/*.sh \| wc -l` → 0 — die Zuordnung ist für alle 92 entscheidbar |
| 5 | Nur **2** Fälle haben einen eigenen `verify`-Modus | `sed -n 's/^# verify: //p' test/mutations/*.sh` → `smoke`, `ci-lint` |
| 6 | Der Go-Build läuft **ohne Kompilat-Cache** | Dockerfile: `GOCACHE` nur als `ENV`, kein Cache-Mount — **out of scope hier** (Hebel B, s. §6) |

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` | update | `test` in `test-bats` + `test-go` zerlegen; `test` bleibt **beide** (die Gate-Kette ändert sich nicht) |
| `harness/tools/mutate.sh` | update | Sensor je Fall aus der `expect`-Zeile ableiten; Default = voller Satz (fail-closed) |
| `test/mutate-driver.bats` | update | die Zuordnungs-Funktion direkt testen: Go-Name → Go-Stufe, anderes → bats, leer/unbekannt → beides |
| `test/mutations/` | neu | ein Fall, der die Zuordnung entschärft (immer nur bats) — muss den Driver-Test röten |
| [`AGENTS.md`](../../../../AGENTS.md), [`harness/README.md`](../../../../harness/README.md) | update | die `mutate`-Beschreibung nennt die Sensor-Wahl |

## 4. Trigger

**`open` → `in-progress`:** Nutzer-Beobachtung vom 2026-07-27 (Laufzeit > 15 min) und die
Ist-Messung oben. Bewusst **nach** der welle-08-Closure: der Umbau betrifft genau das Werkzeug, das
deren Belege lieferte — eine Welle mit einem frisch umgebauten, noch nirgends rot gesehenen Sensor
zu schließen, wäre die Umkehrung der Regel, die dieses Repo durchsetzt.

Rückführungen:

- `in-progress` → `next`: falls die Zerlegung von `make test` mehr berührt als erwartet (CI-Workflow,
  `full-smoke`, emittierte Ziele) — dann trennt ein Re-Slice die Makefile-Zerlegung von der
  Sensor-Wahl.
- `in-progress` → `open`: falls die Messung zeigt, dass der Gewinn gering ist (Hauptkosten liegen
  woanders, etwa im Kontext-Transfer). Dann ist der Umbau nicht gerechtfertigt, und der Befund
  gehört als Messung in den Backlog statt als Code ins Repo.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit ausgestelltem Verdikt; Verifikation bestätigt die DoD
(Modul 11) — **insbesondere, dass die Aussage des Laufs unverändert ist**; `make gates` und
`make mutate` grün; `git mv` nach `done/` (eigener Move-Commit, Link-Reconciliation im Folge-Commit);
Closure-Notiz mit beiden Laufzeiten und einem Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Das größte Risiko ist ein schnellerer Lauf, der weniger prüft.** Genau dagegen steht DoD (2):
  dieselbe Fall-Zahl, dieselben roten Wächter. Ein Fall, der seinen Sensor **nicht** mehr fährt,
  bestünde still — die Klasse „grün über einer Teilmenge", gegen die dieses Repo mehrfach
  angetreten ist. Deshalb ist die Zuordnung **fail-closed**: im Zweifel beide Sensoren.
- **Die `expect`-Zeile bekommt eine zweite Aufgabe.** Sie ist heute Dokumentation und
  Erwartungswert; sie wird zusätzlich **Steuergröße**. Das ist vertretbar (alle 92 Fälle haben sie,
  gemessen), macht sie aber zu einem Ort, an dem ein Tippfehler die Abdeckung verschiebt — der
  Driver-Test in DoD (2) ist die Antwort darauf.
- **`make test` bleibt unverändert die Summe beider Stufen.** Die Gate-Kette und die CI dürfen sich
  nicht ändern; nur `mutate` wählt.
- **Hebel B ist ausdrücklich NICHT in diesem Slice** (Kompilat-Cache für den Go-Build). Er berührt
  eine Gate-Aussage: ein warmer `GOCACHE` lässt `go test` auch **Ergebnisse** cachen, womit „die
  Tests sind wirklich gelaufen" nicht mehr stimmt. Die saubere Form wäre Cache-Mount **plus**
  `-count=1` — eigener Zuschnitt, eigene Entscheidung.
- **Parallelität ist NICHT der Hebel** (gemessen): der Lock schützt seit slice-047 nicht mehr den
  Arbeitsbaum (der ist isoliert), sondern die **geteilten Docker-Image-Tags**. Parallele Fälle
  bräuchten fall-eindeutige Tags und damit einen Eingriff in die `make test`-Kette des Ziels.
- **Kein Carveout absehbar.**

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
[`harness/conventions.md`](../../../../harness/conventions.md) führt `*` (gesamtes Repo) und
`harness/tools/` als **Greenfield**. Der Vollblock entfällt damit laut Template.
