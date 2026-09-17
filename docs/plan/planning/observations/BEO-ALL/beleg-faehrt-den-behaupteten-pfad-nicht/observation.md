# Beleg fährt den behaupteten Pfad nicht

**Sub-Area:** `*` (gesamtes Repo)

Eine Aussage über eine Code-Änderung nennt als Beleg eine Messung, die den geänderten Code nicht
ausführt. Die Aussage kann trotzdem stimmen; getragen wird sie dann von etwas anderem, das nicht
dasteht. Die Fehlerrichtung ist *die Messung deckt die Änderung*: Wer den Beleg liest, hält den
geänderten Pfad für gefahren.

Zwei Nachbarklassen decken den Fall nicht.
[`senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens`](../senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens/observation.md)
misst Inhalts-Mengen statt Verhalten; hier ist Verhalten gemessen, nur auf einem Pfad, der die
Änderung nicht erreicht.
[`stellen-messung-als-eigenschaft-ausgegeben`](../stellen-messung-als-eigenschaft-ausgegeben/observation.md)
gibt eine Stelle als Eigenschaft des Ganzen aus, zu dem sie gehört; hier gehört die gemessene
Stelle nicht zu dem, worüber die Aussage spricht.
