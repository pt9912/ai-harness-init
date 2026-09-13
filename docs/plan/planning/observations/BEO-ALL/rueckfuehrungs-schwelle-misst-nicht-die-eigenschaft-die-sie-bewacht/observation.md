# Rückführungs-Schwelle misst nicht die Eigenschaft, die sie bewacht

**Sub-Area:** `*` (gesamtes Repo)

§4 eines Slice-Plans benennt eine Rückführung vorab und gibt ihr eine **konkrete Schwelle**. Die
Schwelle zählt eine Größe, die im Diff leicht ablesbar ist — Funktionen, Dateien, Zeilen —, statt
der Eigenschaft, die die Rückführung bewacht: *zu groß* ist im Baseline-Regelwerk
`modul-05-planning-harness.md` §Ziel-Form: Slice über drei Kriterien bestimmt (Liefer-Punkte,
berührte Schichten, Prüfbarkeit in einer Review-Sitzung), und keines davon zählt Artefakte eines
Diffs. Die Fehlerrichtung ist *die Rückführung feuert*, während die bewachte Eigenschaft nicht
vorliegt — ein falsch-positiver Wächter, dessen vorgeschriebene Folge (den Slice zerschneiden) den
Schnitt schlechter machen würde als er ist.

Die Kosten fallen **zweifach** an, und die zweite Hälfte ist die teurere: Ein Lauf, der vor einer
Schwelle steht, die seine Lage nicht beschreibt, misst die nächstgelegene ähnliche Größe und
schließt daraus. So entsteht neben dem falschen Maßstab ein ungedeckter Schluss, der niemandem
auffällt, weil beide Zahlen stimmen.

Zwei Nachbarklassen teilen die Ursache — ein Maßstab, dessen Bezugsgröße nicht die zugesagte ist —
und decken den Fall nicht:
[`abnahme-kriterium-bindet-das-gelieferte-artefakt-nicht`](../abnahme-kriterium-bindet-das-gelieferte-artefakt-nicht/observation.md)
trifft den **DoD**-Punkt und hat die umgekehrte Fehlerrichtung (*das Kriterium bestätigt*, statt
zu feuern);
[`closure-kriterium-ohne-erreichbare-messstelle`](../closure-kriterium-ohne-erreichbare-messstelle/observation.md)
setzt ein Instrument voraus, das die Messstelle nicht erreicht — hier ist die Messstelle
erreichbar und die **Größe** falsch gewählt.
