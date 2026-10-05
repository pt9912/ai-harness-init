# Werkzeug-Zelle trägt einen Ist-Stand, der vom ausgelieferten abweicht

**Sub-Area:** `*` (gesamtes Repo)

Die Prosa einer Werkzeug-Zelle nennt einen Stand, der nicht mehr der gültige ist: `make traeger-fetch` pinnt `v0.2.1` fest, obwohl `v0.2.7` ausgeliefert ist; `make artifact-host` nennt `slice-048`, eine Nummern-Kennung statt der Beschreibung des Verhaltens. Kein Sensor liest den Wortlaut einer Zelle gegen den Stand, den sie beschreibt.
