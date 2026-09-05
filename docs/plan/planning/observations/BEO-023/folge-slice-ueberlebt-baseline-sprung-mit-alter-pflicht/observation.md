# Folge-Slice überlebt Baseline-Sprung mit alter Pflicht

**Sub-Area:** `*` (gesamtes Repo)

Ein Folge-Slice wartet in `open/` über einen Baseline-Sprung hinweg, und der Sprung ändert die
Pflicht, die er halten soll — kein Schritt hält den Bestand offener Slice-Pläne gegen den neuen
Stand; die Fehlerrichtung ist *der Plan gilt weiter* statt *seine Frage hat sich verschoben*.
