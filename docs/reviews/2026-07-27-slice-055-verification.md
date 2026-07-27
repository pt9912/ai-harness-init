# Verifier-Report slice-055 — Ein Kommentar nennt seinen Sensor oder behauptet nichts

Rolle: **Verifier (Modul 11)**, getrennt von Implementation und Review. Prüfgegenstand ist die
**DoD-Behauptung**, nicht die Code-Qualität. *„Behauptung ohne Bestätigung ist die häufigste
Verifier-Lücke"* — hier besonders passend: der Slice baut ein Gate gegen genau diese Klasse.

**Datum:** 2026-07-27. **Slice:** `docs/plan/planning/in-progress/slice-055-kommentare-nennen-ihren-sensor.md`.
**Range:** `644f401..6150f6b`.

**Grenze:** kein frischer Kontext (Modul 8); kompensiert durch Kommandos statt Erinnerung.

## Was ich selbst erhoben habe

| DoD-Punkt | Kommando | Ergebnis |
|---|---|---|
| (1) Ist-Bestand bereinigt | `make comment-claims` über den realen Prüfbereich | **30 Datei(en), 0 Befund(e)** — die zehn Fundstellen des Sweeps sind weg, und der Gate selbst ist der Beleg (kein Durchsehen) |
| (1) die falsche Behauptung ist weg | `sed -n '73,75p' internal/gen/gen.go` | benennt jetzt, dass Stufe (2) **keinen** Sensor hat, statt einen zu behaupten |
| (2) Gate hermetisch und in `gates` | `grep -n "comment-claims" Makefile` | eigenes Target ohne Docker/Netz, in der `gates`-Kette **vor** `record-gates` |
| (2) Roh-String-Ausnahme | bats „Roh-String-Literal ist ausgenommen" + „…ist eng: NACH dem Literal wird wieder geprueft" | beide grün — die Ausnahme greift und kippt korrekt zurück |
| (3) Zähne, Sensor-Erkennung | Mutation **94** (Sensor-Erkennung immer wahr) | **rot gesehen** → `Behauptung OHNE Sensor-Nennung` fällt |
| (3) Zähne, Roh-String-Ausnahme | Mutation **95** (Ausnahme entfernt) | **rot gesehen** → `Roh-String-Literal ist ausgenommen` fällt |
| (3) Zähne, erfundener Name | bats „erfundener Testname: rot" | grün — und der Fall stammt aus einem realen Fehler des Autors |
| Gates | `make gates` | **Exit 0** (d-check 205/0, comment-claims 30/0, 0 `not ok`) |
| Mutate | `make mutate` | **91 ok, 0 Befunde** |
| Doku | `grep -n "comment-claims" AGENTS.md harness/README.md` | je eine Gate-Zeile |

## DoD-Stand

**Bestätigt: alle drei slice-eigenen Punkte + `make gates`/`make mutate` + Doku.**
**Offen:** Closure-Notiz (Planner).

**Eine Beobachtung, die der Verifier festhalten muss, weil sie sonst verloren geht:** der Slice
hat seinen eigenen Zwischenstand **einmal falsch gemeldet**. Nach dem ersten `make mutate` stand
ein `BEFUND` (Fall 95 ohne Zähne) — die Implementation hatte den bats-Fall zu diesem Zeitpunkt
bereits als erfüllt betrachtet. Erst der Mutations-Lauf widerlegte das. Für die DoD-Abnahme zählt
der **zweite** Lauf (91 ok / 0); die Reihenfolge gehört in die Closure-Notiz, weil sie die
eigentliche Lehre trägt.

## Zu den Review-Findings

F-1 bis F-4 sind aufgelöst und je rot gesehen. Aus Verifier-Sicht ist die Verteilung das
Bemerkenswerte: **drei von vier betrafen den Wächter, nicht den bewachten Code** — ein neu
gebauter Sensor ist selbst so lange unbelegt, bis er einmal rot war. F-5 (Form statt Bedeutung)
und F-6 (enger Prüfbereich) sind benannte Grenzen und berühren keinen DoD-Punkt; F-6 ist der
konkreteste Backlog-Kandidat (`test/**` mitscannen).

## Verdikt

**DoD bestätigt (alle prüfbaren Punkte).** Keine Rückkante zur Implementation. Die
Reihenfolge „grün gemeldet → Mutation widerlegt → korrigiert → grün" ist in der Closure
festzuhalten, nicht zu glätten.
