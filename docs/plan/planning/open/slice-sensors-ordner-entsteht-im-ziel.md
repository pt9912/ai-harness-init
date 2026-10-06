# Slice slice-sensors-ordner-entsteht-im-ziel: Das gebootstrappte Ziel trägt den Ordner harness/sensors/

**Welle:** ohne Welle.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) Festlegung 1.

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-06.

---

## 1. Ziel und Abgrenzung


**Ziel:** Der Bootstrap legt im Ziel den Ordner `harness/sensors/` an (Träger `.gitkeep` (Ordner `harness/sensors/`), skip-if-present), damit der Verweis `harness/sensors/<target>.md` der emittierten README-Vorlage auf einen vorhandenen Ort zeigt — ohne Wächter, mit benannter Grenze.

**Messung vor dem Schnitt** (Pin v0.79.0, Scratch-Ziel `--lang go`): `structure` meldet Nicht-Existenz nur als `section-missing` einer Regel mit `files: "harness/sensors/*.md"`; es gibt keinen Ordner-Selektor. Kein Ordner, leerer Ordner und Ordner mit nur `.gitkeep` melden dasselbe Rot (3 von 3), eine `.md` mit einem Satz gibt Grün, eine leere `.md` `section-missing`. Am frischen Ziel wäre die Regel rot (null Dateien) und widerspräche der Vorlage, die die Datei nur für ein Target mit mehr als einem Satz Vertrag vorsieht; das Kriterium grüner Start aus [`MR-054`](../../../../harness/conventions.md#mr-054) trüge sie nicht.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Eine `structure`-Regel, die die Existenz fordert — am frischen Ziel rot (Messung oben); Träger ist der Emitter-Test, nicht ein Doku-Gate-Modul.
- Eine Sensors-Datei im Ziel — die Vorlage macht sie bedingt; eine erzeugte Datei wäre eine erfundene Sensor-Beschreibung.
- Das Modul `targets` im Ziel — Folge-Slice `slice-targets-modul-im-emittierten-doc-gate`, der den Ordner nicht braucht (er prüft Makefile gegen README-Tabelle).
- Dieses Repo (Dogfood) — der Ordner besteht hier; der Slice betrifft nur das Emittierte.

## 2. Definition of Done

- [ ] Der Bootstrap schreibt `.gitkeep` (Ordner `harness/sensors/`) an einem freien Pfad (skip-if-present, [`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md)); ein Test in `internal/emit` hält es, und die Emitter-Zeile entfernt färbt ihn rot (Gegenbeispiel gesehen, AGENTS.md §3.6).
- [ ] `make full-smoke` misst im Ziel, dass `.gitkeep` (Ordner `harness/sensors/`) nach dem Bootstrap in `git ls-files` steht; die E2E-Abdeckungs-Sicht nennt die Stufe mit ihrer Grenze (Ordner, nicht Inhalt).
- [ ] Die Grenze steht am Ort der Emission (Kopfkommentar `internal/emit/templates.go`): kein Wächter für die Existenz des Ordners, Messung wie oben.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`) — kein Self-Review.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis oder weitere Datei in `evidence/`; kein Zähler wird gesetzt. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo ohne Wellen-Betrieb hier geprüft.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit` (Datei-Liste, Klassen-Kommentar in `templates.go`) | update | `.gitkeep` als skip-if-present-Träger; Grenze am Ort |
| Emitter-Test in `internal/emit` | update | Happy (Ordner entsteht), Boundary (zweiter Lauf, Pfad besetzt) — [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) |
| `harness/tools/full-smoke.sh` | update | Stufe samt Abdeckungs-Deklaration; `docs/user/e2e-abdeckung.md` per `make e2e-abdeckung` neu erzeugt |

## 4. Trigger


**Start** (`next` → `in-progress`): Auftrag des Auftraggebers; keine Abhängigkeit.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): ein vierter Liefer-Punkt wird nötig.
- `in-progress` → `open` (blockiert — Carveout?): [`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) Festlegung 1 trägt einen leeren Träger nicht — dann ist es eine Architect-Frage, nicht Slice-Arbeit.

## 5. Closure-Trigger


DoD vollständig, `make gates` und `make full-smoke` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte


- `.gitkeep` fehlt nach einem Löschen im Ziel unbemerkt (kein Wächter, Messung oben) — **Ausgang:** weiter offen: → BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht

## 7. Closure-Notiz


Wird bei der Closure vom Planner geschrieben (AGENTS.md §3.10), nicht im Plan.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** eine Sub-Area, `*` (`ALL`), Schwelle erfüllt; Modus Greenfield — alle berührten Sub-Areas GF.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (`ls docs/plan/planning/observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/evidence | wc -l` → 5, bereits über der Schwelle; dieser Slice nennt seine Zusage mit Grenze) und `BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus` (`ls …/emittierter-stand-laeuft-dem-dogfood-voraus/evidence | wc -l` → 2). Zähler gelesen am gemergten Stand 2026-10-06.

