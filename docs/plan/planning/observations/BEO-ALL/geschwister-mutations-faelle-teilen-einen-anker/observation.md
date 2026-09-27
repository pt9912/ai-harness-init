# Zwei Geschwister-Mutations-Fälle teilen einen überlappenden `sed`-Anker

**Sub-Area:** `*` (gesamtes Repo)

Zwei Mutations-Fälle, die denselben Wächter gegen zwei verschiedene Verstoß-Instanzen binden,
ankern beide auf demselben Wortlaut-Teilstring einer Zeile und mutieren an unterschiedlicher
Stelle innerhalb desselben Match. Nach MR-071 ist das zulässig — die Regel bindet den Anker **je
Fall** gegen den Quell-Bestand, nicht die Anker zweier Geschwister-Fälle gegeneinander. Eine
künftige, berechtigte Wortlaut-Änderung an genau dieser Zeile entwaffnet in dieser Lage aber
typischerweise **beide** Fälle gleichzeitig, nicht nur einen — dieselbe „dritte Fundmenge", die
MR-071 (§Die drei Fundmengen, Punkt 3) für den Einzelfall bereits benennt, hier auf ein Paar
korreliert.
