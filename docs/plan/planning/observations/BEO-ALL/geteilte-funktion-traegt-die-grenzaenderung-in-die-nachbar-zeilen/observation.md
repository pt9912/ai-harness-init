# Geteilte Funktion trägt die Grenzänderung in die Nachbar-Zeilen

**Sub-Area:** `*` (gesamtes Repo)

Eine Änderung verschiebt eine Grenze für eine Zeilenklasse — hier die Zeilen mit Zuweisung —, die
Funktion dahinter ist aber für alle Zeilen dieselbe, und die Verschiebung wirkt auf die Klasse
daneben: die Zeilen ohne Zuweisung. Die Nachbarklasse hat keinen eigenen Test, und der Plan spricht
nur von der ersten; die Wirkung fällt erst einer Sonde auf und berührt keinen DoD-Punkt. Die
Fehlerrichtung ist *die Änderung betrifft nur ihren Gegenstand*.
