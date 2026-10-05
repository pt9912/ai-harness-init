# Slice slice-werkzeug-zellen-tragen-ihre-prosa-unter-sensors: Lange Werkzeug-Zellen tragen ihre Prosa unter harness/sensors/

**Welle:** ohne Welle.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (genannte Targets ohne halluzinierte Aussage), [`ADR-0045`](../../adr/0045-authority-wechsel-senkt-eine-richtung.md) (Autoritäts-Datei des Moduls `targets`).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-10-05.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die Prosa der sechs längsten Zellen der Tabelle „Werkzeuge (kein Gate)" in `harness/README.md` steht je Target in `harness/sensors/<target>.md`; die Zelle behält einen Satz, den Link und die Bindung. Kandidatenmenge am Befund (Zeichen je Tabellenzeile, `awk '/^### Werkzeuge/{f=1;next} /^#/{f=0} f && /^\| / {print length($0), $2, $3}' harness/README.md | sort -rn | head -9`): `tap-nachzug` 1592 · `tap-check` 1258 · `e2e-abdeckung` 1062 · `traeger-fetch` 711 · `artifact-host` 430 · `test-go-pids-guard` 382 · dann `mutate` 345 (hat die Datei schon) und 278 abwärts. Die Menge endet an der Lücke 382 → 345 und an der Regel „keine Zelle ohne Datei über der Länge von `mutate`"; `artifact-host` kommt zu den fünf Zielen des Auftrags hinzu, weil sie länger ist als `test-go-pids-guard`.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Kein inhaltliches Umschreiben der Verträge — Wortlaut wird verschoben, nicht überarbeitet; sonst ist eine Verschiebung nicht von einer Überarbeitung zu trennen, und kein Sensor hält den Unterschied (Lücke in §2 benannt).
- Keine Änderung der Tabellenstruktur (Spalten, Zeilenfolge, andere Zeilen) — ein anderer Vorgang; die Tabelle bleibt die Autoritäts-Zeile für `targets` (`.d-check.yml`).
- Zellen, die nur wegen eines Ist-Stand-Fehlers korrigiert werden müssten, werden nicht korrigiert, sondern als Beobachtung ins Register gelegt (Ausgang *weiter offen*) — ein Wortlaut-Fix wäre Umschreiben; eine Folge-Slice-Datei gibt es nicht, ein Fund bekommt den Register-Weg.
- Zeilen unter der Länge von `mutate` (345) bleiben unberührt — Bestand, der Satz trägt; ein Schwellen-Sensor existiert nicht und wird hier nicht gebaut (anderer Vorgang).
- Keine Zeilen der Tabelle §Sensors und keine `docs/user/`-Texte — andere Schicht; ein Verweis dort auf die Zelle als Quelle wird nur nachgezogen, nicht umformuliert.

## 2. Definition of Done

Liefer-Punkte (drei, je zwei Ziele):

- [ ] **Tap:** die sensors-Datei von `tap-check` und die sensors-Datei von `tap-nachzug` tragen den Wortlaut der heutigen Zellen; die Zellen führen einen Satz + Link + Bindung.
- [ ] **Erzeugung und Fetch:** die sensors-Datei von `e2e-abdeckung` und die sensors-Datei von `traeger-fetch` ebenso (Prosa aus „Tut was" **und** aus der Bindungs-Zelle von `e2e-abdeckung`; dort bleiben nur die Klassen-Marken `kein Gate`, die `LH-*`-Links).
- [ ] **Rest:** die sensors-Datei von `artifact-host` und die sensors-Datei von `test-go-pids-guard` ebenso.

Gemeinsame Messung der drei Punkte (kein Sensor hält sie, **Lücke benannt**: `docs-check` prüft Links und Anker, `targets` Zeilen gegen Rezepte — keiner vergleicht Wortlaut):

- [ ] Wort-für-Wort-Vergleich: Zelltexte der sechs Zeilen vor dem Eingriff in den Scratch-Bereich ziehen; je Datei ist der Wortlaut dort enthalten, ausgenommen die mechanisch angepassten Link-Präfixe (`](../` → `](../../`, `](sensors/x.md)` → `](x.md)`, `](conventions.md` → `](../conventions.md`); Diff nach Normalisierung leer. Kommando und Ergebnis stehen im Bericht.
- [ ] Rot gesehen: Link einer Zelle auf eine nicht vorhandene Datei gesetzt → `make docs-check` rot (Meldung gelesen); sensors-Datei weggenommen, Link bleibt → rot. Zurückgenommen.
- [ ] Bindungs-Zählung unverändert: der Messblock in `harness/conventions.md` §Zusatzklassen-Deklaration liefert vor und nach dem Eingriff dieselben Zahlen je Klasse.
- [ ] `make gates` grün. Review (`.harness/skills/reviewer.md`), Closure-Notiz mit Lerneintrag, Beobachtungs-Register fortgeschrieben, jedes Risiko aus §6 mit Ausgang, die drei Paarungen getragen.

## 3. Plan (vor Code)

Messungen vor dem Schnitt (am Baum gelesen, nicht aus dem Auftrag):

- `targets`-Block: `makefiles: [Makefile, d-check.mk]`, `doc-tables: [AGENTS.md, harness/README.md]`, `authority: harness/README.md` (ganze Datei, kein Heading-Scoping). Alle sechs Ziele stehen in `exempt-targets`. Die Zeilen bleiben, damit trägt die Verschiebung **keine** Kopplung: die Phantom-Richtung (Tabellenzeile ohne Rezept) bleibt grün, `gate-undocumented` greift für exempte Ziele ohnehin nicht, `test/targets-modul-wiring.bats` scopt auf §Sensors, nicht auf Werkzeuge. Kein Modul verlangt eine sensors-Datei je Target.
- Was die Verschiebung brechen kann: `links`/`anchors` des Doku-Gates (falscher Pfad, Präfix), `codepaths` (`harness`-Wurzel: Inline-Pfade im verschobenen Text lösen von der neuen Datei aus), `check-lines`/Zitate falls die Zellen zitiert werden.
- Nur Bindung: `docs/user/rollen-laeufe.md` verlinkt den Abschnitts-Anker `#werkzeuge-kein-gate`, nicht eine Zelle — unberührt.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/sensors/<target>.md` ×6 | neu | Form der vorhandenen Dateien: `# \`make X\` — Titel`, `## Vertrag` (Wortlaut der Zelle), bei Bedarf `## Grenze` |
| `harness/README.md` §Werkzeuge | update | sechs Zellen: Satz + Link + Bindung |
| `.claude/commands/` / Tests | keine | nichts liest den Zellentext (`grep -rn` über `test/`, `harness/tools/`, `internal/` gemessen: nur Pfad-Erwähnungen) |

Reihenfolge: erst die Dateien anlegen (Commit 1), dann die Zellen kürzen (Commit 2) — Inhaltsänderungen, kein `git mv`.

## 4. Trigger

**Start** (`next` → `in-progress`): keine Abhängigkeit; Auftrag des Auftraggebers (Auslöser 1).

**Rückführungen:**

- `in-progress` → `next`: die Kandidatenmenge wächst über sechs, oder der Wortlaut lässt sich nicht ohne Umschreiben an der Satz-Grenze teilen.
- `in-progress` → `open`: ein Doku-Modul koppelt wider Erwarten an den Zellentext.

## 5. Closure-Trigger

`make gates` grün (einmal am Ende), Wort-für-Wort-Diff leer, `make docs-check` rot gesehen am gebrochenen Link. Lerneintrag: neuer Sensor oder benannte Lücke (kein Wortlaut-Vergleich, keine Zellen-Längen-Schranke).

## 6. Risiken und offene Punkte

- Der Wortlaut driftet beim Verschieben (Pipe-Escapes, Zeilenumbruch, Link-Präfix) — **Ausgang:** bei Closure (Planner) nach dem Diff-Befund.
- Eine Zelle verlinkt eine andere, vorhandene sensors-Datei: `links` bleibt grün, nichts hält Zelle gegen Datei — **Ausgang:** bei Closure; Review liest je Zeile Link und Dateititel.
- „Ein Satz" ist Urteil; ein Sensor auf Zellenlänge bräuchte eine Schranke, und eine „mindestens/höchstens N"-Schranke wird durch Tabellenwachstum unscharf (`BEO-ALL/sensor-schranke-wird-durch-tabellenwachstum-unscharf`) — **Ausgang:** bei Closure: *weiter offen* oder Evidenz.
- Eingefroren: Zeitdokumente nennen README und Ziel auf derselben Zeile (`grep -lE 'README\.md.*tap-check|tap-check.*README\.md' docs/plan/planning/done/*.md docs/reviews/*.md | wc -l`); `docs/plan/adr/` null. Es bewegt sich kein Pfad (README bleibt, `sensors/` ist stehende Ablage, die Zelle hat keinen Anker), §3.11 verlangt hier keine Entscheidung vor dem Move — **Ausgang:** entfallen mit dieser Begründung; Implementer misst die Aussage vor dem Eingriff nach.

## 7. Closure-Notiz

- **Was hat funktioniert:** <bei Closure>
- **Was ging anders als geplant:** <bei Closure>
- **Steering-Loop-Eintrag:** <bei Closure>
- **Beobachtungs-Register (`../observations/`):** <bei Closure>
- **Folge-Slices:** <bei Closure>
- **Risiken aus §6:** <bei Closure — jedes mit genau einem Ausgang>
- **Drei Paarungen:** <bei Closure>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** eine Sub-Area, `*` (gesamtes Repo, `ALL`); Schwelle erfüllt, nichts auszudifferenzieren.

**Vorgelagert — offene Beobachtungen sichten:** `ls docs/plan/planning/observations/BEO-ALL | wc -l` gelesen; Treffer: `sensor-schranke-wird-durch-tabellenwachstum-unscharf` (`ls docs/plan/planning/observations/BEO-ALL/sensor-schranke-wird-durch-tabellenwachstum-unscharf/evidence | wc -l` → Zähler 1, offen; berührt über die Frage der Längen-Schranke, wird hier nicht gehoben) und `prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle` (verkörpert; berührt, weil die Quelle der Wiedergaben wandert — Implementer prüft `docs/user/` auf Zeiger auf die Zellen).

**Modus-Begründungsblock:** alle berührten Sub-Areas GF.

