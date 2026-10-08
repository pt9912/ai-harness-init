# Architect-Verdikt — slice-211-codepaths-im-emittierten-doc-gate

**Eingang:** Review-Report `2026-10-08-slice-211-review.md` F-1 (MEDIUM) und die Frage aus dem
Implementer-Bericht zu `exempt-paths` im emittierten `codepaths`-Block.
**Rolleninhaber:** Architect-Lauf vom 2026-10-08.

## 1. F-1 — Norm-Text führt `codepaths` als ausbleibend

**Verdikt: Norm nachgezogen, Aktivierung bleibt.** Neuer Eintrag
[`MR-087`](../../harness/conventions.md#mr-087--das-modul-codepaths-verlässt-die-ausbleibenden-positionen-des-emittierten-doc-gates):
`codepaths` verlässt Setzung 3 von `MR-054`, die zwei verbleibenden Positionen sind das
Requirement-Muster von `ids` und `reviews`. Kopf-Marken nach `MR-032` an `MR-054` (Position
`codepaths`) und `MR-086` (der Vergleich *„in derselben Form wie `codepaths`"*). Kein
Implementer-Fix; die Closure ist von F-1 nicht mehr blockiert.

## 2. `exempt-paths: ["docs/reviews/**"]` im emittierten `codepaths`-Block

**Verdikt: ja.** Ein Review-Report ist ein Zeitdokument
([`AGENTS.md`](../../AGENTS.md) §3.7); ein Pfad darin nennt den Stand seines Laufs. Das
`slice-mv` des Ziels zieht einen **verschobenen** Pfad nach, einen **gelöschten** nicht — der
Adopter bekommt dann `codepath-missing` in einer Datei, die er nicht ändern soll, also ein Rot aus
Werkzeug-Form statt aus Adopter-Inhalt (`MR-054` Setzung 2). Dieselbe Datei nimmt die Reports im
`matrix`-Block aus demselben Grund aus, der Dogfood ebenso; eine abweichende Position im selben
Ziel wäre ohne Grund.

Die Position liegt innerhalb des Blocks, also unter der Ziel-Form und nicht unter `MR-054` — kein
Norm-Eintrag nötig. **Übergabe an den Implementer:** in `internal/emit/templates/d-check.yml` den
Block um `exempt-paths: ["docs/reviews/**"]` ergänzen, den Satz *„Auch docs/reviews/\*\* ist
geprueft."* im Kopfkommentar und die Prosa in `internal/emit/templates/commands/implement-slice.md`
nachziehen; der Zahn *codepath-missing* in `harness/tools/full-smoke.sh` liegt in
`spec/lastenheft.md` und bleibt rot. **Grenze im Plan:** §1 schließt die Positionen innerhalb von
`codepaths` aus — die Erweiterung ist eine Zeile in §1, die der Planner setzt
([`AGENTS.md`](../../AGENTS.md) §3.10), nicht der Implementer.

**Akzeptiertes Negativ:** Ein Pfad in einem Report wird im Ziel nicht mehr auf Existenz geprüft.
Das ist gewollt — der Report ist keine Zusage über den heutigen Baum.
