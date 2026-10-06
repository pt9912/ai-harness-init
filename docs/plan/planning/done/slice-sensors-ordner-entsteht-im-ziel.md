# Slice slice-sensors-ordner-entsteht-im-ziel: Das gebootstrappte Ziel trägt den Ordner harness/sensors/

**Welle:** ohne Welle.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) Festlegung 1.

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

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

- [x] Der Bootstrap schreibt `.gitkeep` (Ordner `harness/sensors/`) an einem freien Pfad (skip-if-present, [`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md)); ein Test in `internal/emit` hält es, und die Emitter-Zeile entfernt färbt ihn rot (Gegenbeispiel gesehen, AGENTS.md §3.6).
- [x] `make full-smoke` misst im Ziel, dass `.gitkeep` (Ordner `harness/sensors/`) nach dem Bootstrap in `git ls-files` steht; die E2E-Abdeckungs-Sicht nennt die Stufe mit ihrer Grenze (Ordner, nicht Inhalt).
- [x] Die Grenze steht am Ort der Emission (Kopfkommentar `internal/emit/templates.go`): kein Wächter für die Existenz des Ordners, Messung wie oben.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`) — kein Self-Review.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis oder weitere Datei in `evidence/`; kein Zähler wird gesetzt. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo ohne Wellen-Betrieb hier geprüft.

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


- `.gitkeep` fehlt nach einem Löschen im Ziel unbemerkt (kein Wächter, Messung oben) — **Ausgang:** weiter offen → `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (verkörpert; Beleg dieses Vorgangs ergänzt).

## 7. Closure-Notiz


- **Was hat funktioniert:** Emitter schreibt `.gitkeep` (Ordner `harness/sensors/`) skip-if-present, Test in `internal/emit` färbt ohne die Emitter-Zeile rot; die `full-smoke`-Stufe `sensors_ordner_im_ziel` misst `git ls-files` im Ziel, ihr gestrichener Eintrag färbt die Abdeckungs-Sicht rot (Review: keine Findings, 1 INFO; Verifikation: DoD 1–3 bestätigt; `docs/reviews/2026-10-06-sensors-ordner-review.md`, `-verifikation.md`).
- **Was ging anders als geplant:** die Zusage hängt an einer Bedingung, die §6 nicht nannte — die `.gitignore` des Adopters.
- **Grenze (gemessen, Verifikation):** eine Adopter-`.gitignore` mit `*.gitkeep`, `.gitkeep` oder `harness/sensors/` lässt den Träger ungetrackt — Bootstrap Exit 0 ohne Meldung, `git ls-files harness/sensors` nach `git add -A` leer, ein Klon trägt den Ordner nicht. Die Zusage „der Verweis zeigt auf einen vorhandenen Ort" gilt dort nur für die Arbeitskopie; weder die Stufen-Deklaration noch der Kopfkommentar in `internal/emit/templates.go` nennen den Fall, und `make full-smoke` misst nur das Ziel ohne Adopter-`.gitignore`.
- **Steering-Loop-Eintrag:** benannte Lücke, kein Sensor: ein skip-if-present-Träger im Ziel ist erst getragen, wenn er auch an der Ignorier-Konfiguration des Adopters vorbeikommt; die E2E-Stufe misst den leeren Grund. Träger ist der Lauf, der die Aussage schreibt (`AGENTS.md` §3.6, emittierte Abdeckungs-Aussage).
- **Beobachtungs-Register (`../observations/`):** `evidence/slice-sensors-ordner-entsteht-im-ziel.md` in `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/` ergänzt; der Eintrag ist bereits verkörpert, kein neuer Ausgang.
- **Folge (kein Slice angelegt):** Stufen-Deklaration und Kopfkommentar nennen die `.gitignore`-Grenze — Adresse `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`.
- **Risiken aus §6:** (1) weiter offen → Register (Eintrag oben).
- **Drei Paarungen:** dieses Repo fährt Wellen — Anker, Folge-Slice und Register prüft die nächste Welle-Closure, auch für diesen Slice ohne Wellen-Zugehörigkeit.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** eine Sub-Area, `*` (`ALL`), Schwelle erfüllt; Modus Greenfield — alle berührten Sub-Areas GF.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (`ls docs/plan/planning/observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/evidence | wc -l` → 5, bereits über der Schwelle; dieser Slice nennt seine Zusage mit Grenze) und `BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus` (`ls …/emittierter-stand-laeuft-dem-dogfood-voraus/evidence | wc -l` → 2). Zähler gelesen am gemergten Stand 2026-10-06.

