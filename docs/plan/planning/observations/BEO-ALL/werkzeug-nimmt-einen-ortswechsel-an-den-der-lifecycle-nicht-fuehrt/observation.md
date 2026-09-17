# Werkzeug nimmt einen Ortswechsel an, den der Lifecycle nicht führt

**Sub-Area:** `*` (gesamtes Repo)

Ein Lifecycle-Werkzeug nimmt einen Ortswechsel an, den die Zustandsmaschine nicht führt, etwa
einen Slice, der `done/` wieder verlässt. Dabei schreibt es wie auf einer vorgeschriebenen Kante
in eingefrorene Artefakte. Die Entscheidung, die dieses Schreiben deckt, ist an einen vom Prozess
vorgeschriebenen Ortswechsel gebunden, und für die übrige Kante entscheidet keine Quelle. Die
Fehlerrichtung ist *das Schreiben ist gedeckt*.

Der Nachbar
[`verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
ist für die vorgeschriebenen Kanten verkörpert. Hier fehlt die Kante, an die jene Verkörperung
gebunden ist.
