# Nicht-Gate-Werkzeug ohne funktionalen Wächter

**Sub-Area:** `harness/tools/`

Ein Skript unter `harness/tools/` wird als Nicht-Gate-Werkzeug verankert (Makefile-Ziel,
`kein Gate`-Marke, README-Zeile) — die Verankerung selbst wird dabei mechanisch bewacht
(`docs-check`), die **Aufgabe des Skripts** bleibt es nicht: Ob es misst, was es zu messen
vorgibt, und rechtzeitig meldet, was es zu melden vorgibt, prüft kein Sensor. Die
Doku-Konsistenz-Prüfung deckt *„die Zeile stimmt"*, nicht *„das Skript stimmt"* — zwei
verschiedene Aussagen, von denen nur die erste einen Träger hat.
