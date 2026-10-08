# Teilzeichenketten-Suche bindet einen Pfad nicht an seine Grenze

**Sub-Area:** `*` (gesamtes Repo)

Eine Assertion oder Zuordnung sucht einen Pfad oder eine Kennung per Teilzeichenkette
(`strings.Contains`, Präfix) und bindet ihn an keine Grenze davor oder danach. Ein fremder Wert,
dessen Name den erwarteten enthält oder auf ihn endet (ein vorangestelltes Verzeichnis-Segment), geht
durch. Ein Wächter besteht nicht; Träger ist die Grenz-Sonde im Review.
