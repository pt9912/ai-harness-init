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

- [x] **(1) Die Sensor-Wahl je Fall ist mechanisch und fail-closed.** Die vorhandene
  `# expect:`-Zeile bestimmt, welcher Sensor läuft: nennt sie einen Go-Test (`^Test[A-Z]`), fährt der
  Fall nur die Go-Stufe; sonst nur den bats-Container. **Bei Zweifel der volle Satz** — eine
  unbekannte, leere oder mehrdeutige `expect`-Zeile fährt **beide** Sensoren, nie weniger. Die
  bestehenden `# verify:`-Modi (`smoke`, `ci-lint`) bleiben unberührt.
- [x] **(2) Die Aussage des Laufs ist nachweislich unverändert.** `make mutate` meldet weiterhin
  **92 ok / 0 Befunde**, und **jeder** Fall färbt weiterhin denselben Wächter rot wie vorher —
  belegt durch den Lauf, nicht durch Argumentation. Ein Fall, dessen Sensor **falsch** zugeordnet
  wird, muss auffallen: rot gesehen an einem absichtlich fehl-zugeordneten Fall.
- [x] **(3) Vorher/Nachher ist gemessen, nicht geschätzt.** Laufzeit des vollständigen
  `make mutate` vor und nach dem Umbau, beide Zahlen in der Closure-Notiz. Bleibt der Gewinn unter
  einem Drittel, ist das ein Befund und gehört genannt — nicht weggelassen.
- [x] `make gates` grün, `make mutate` ohne Befund.
- [x] Doku-Update: die `mutate`-Beschreibung in [`AGENTS.md`](../../../../AGENTS.md) §4 und
  [`harness/README.md`](../../../../harness/README.md) sagt, dass je Fall nur ein Sensor läuft.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

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

**Was funktioniert hat — die Zahlen zuerst, weil der Slice sie zur Bedingung gemacht hat.**

| | Vorher | Nachher |
|---|---|---|
| Fälle | 92 | **93** (der neue Wächter auf die Auswahl kommt hinzu) |
| Laufzeit | **19m01s** | **10m54s** |

**−43 %, über einen Fall mehr.** Beide Läufe allein auf dem Docker-Daemon. Wichtiger als die Zeit
ist der zweite Beleg: der **fallweise** Vergleich beider Lauf-Logs zeigt genau **einen**
Unterschied — den neuen Fall. Kein alter Fall hat seinen Wächter verloren. Ein schnellerer Sensor,
der weniger sieht, wäre der einzige Weg gewesen, diesen Slice falsch zu machen.

Der Gewinn liegt **über** der vorab notierten Erwartung (~ein Drittel). Das ist ein Befund, keine
Bestätigung: der bats-Container wiegt mehr, als die reine Go-Build-Rechnung hergab.

**Was anders lief als geplant.**

1. **Das eigene Gate meldete einen Fehlalarm.** Der neue Kommentar erklärte das Auswahl-Muster mit
   einem illustrativen Testnamen — der Existenz-Check aus slice-055 las ihn als Sensor-Verweis und
   färbte `make gates` rot. Eng aufgelöst (Muster statt Name); die breite Lösung (Existenz-Check nur
   in Blöcken mit Behauptung) wäre eine **Gate-Lockerung** und gehört nicht in einen Laufzeit-Slice.
2. **Eine Messung ging verloren.** Gates rot → Fix in `mutate.sh` → die Datei ist während eines
   Laufs gesperrt (sie ist selbst Mutations-Ziel) → laufende Messung abgebrochen, ~10 Minuten weg.
3. **Eine frühere Baseline wurde ebenfalls verworfen** — dort hätte ein parallel nötiger Gate-Lauf
   denselben Docker-Tag gebaut und die Vorher-Zahl **künstlich erhöht**, also den Gewinn geschönt.
4. **DoD (2) war in sich widersprüchlich** („weiterhin 92 ok" **und** ein neuer Wächter). Abgenommen
   wurde die Substanz; dieselbe Klasse wie „byte-identisch" in slice-053.

**Steering-Loop-Eintrag: wer eine Laufzeit misst, misst zuerst die Umgebung.** Beide verworfenen
Läufe scheiterten nicht am Umbau, sondern an **geteilten Ressourcen**: derselbe Docker-Image-Tag,
derselbe Daemon. Eine Messung, die parallel zu `make gates` läuft, ist keine langsamere Messung —
sie ist eine **falsche**, und zwar in die bequeme Richtung. Regel für künftige Laufzeit-Slices:
vor der Messung Gates grün, während der Messung nichts anderes auf dem Daemon, und beide Zahlen
unter identischen Bedingungen.

**Zweiter Eintrag: eine Metadaten-Zeile, die Steuergröße wird, braucht ihre Fail-closed-Regel im
selben Zug.** Die `# expect:`-Zeile war Dokumentation; jetzt entscheidet sie über die Abdeckung. Der
Schutz ist nicht Sorgfalt, sondern die Konstruktion: unbekannt/leer/mehrdeutig → **voller Satz**,
plus ein Mutations-Fall, der genau diesen Rückfall entschärft.

**Folge-Slices.** **Hebel B** ist entschieden und wird direkt im Anschluss geschnitten: Cache-Mount
für den Go-Kompilat-Cache **plus `-count=1`** (ohne das cachte `go test` auch Ergebnisse, und „die
Tests sind wirklich gelaufen" wäre nicht mehr wahr) — mit einem Wächter dagegen, dass `-count=1`
still wieder verschwindet. Er adressiert, was nach diesem Slice übrig ist: 60 Fälle × Go-Build,
davon 94 % Übersetzung. Dazu offen aus Review-F-1: der Prüfbereich des `comment-claims`-Gates
(illustrative Namen vs. behauptete Sensoren) — Kandidat für den bereits notierten slice-055-Punkt.

## 8. Sub-Area-Modus-Begründung

**Alle berührten Sub-Areas GF** (siehe Kurs Modul 5 §Worked Mini-Example): die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) führt `*` (gesamtes Repo) und
`harness/tools/` als **Greenfield**. Der Vollblock entfällt damit laut Template.
