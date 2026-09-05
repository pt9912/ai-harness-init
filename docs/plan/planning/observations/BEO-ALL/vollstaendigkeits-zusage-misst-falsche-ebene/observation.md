# Vollständigkeits-Zusage misst falsche Ebene

**Sub-Area:** `*` (gesamtes Repo)

Eine Vollständigkeits-Zusage über ein Delta misst auf der Datei-Ebene, während ihr Gegenstand auf
der Hunk-Ebene lebt: eine Datei trägt mehrere unabhängige Positionen, und eine Position spannt
über mehrere Dateien — die Zusage kann grün sein, während eine Position ohne Ausgang dasteht.
