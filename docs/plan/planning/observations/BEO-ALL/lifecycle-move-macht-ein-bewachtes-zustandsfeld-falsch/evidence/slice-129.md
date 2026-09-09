**Vorgang:** slice-129
**Fund:** Zweimal in einem Vorgang, an beiden Enden des Lifecycle. Der `git mv` `next/ →
in-progress/` machte den Ruhe-Marker *„Nichts in Arbeit."* der Roadmap falsch; `make docs-check`
meldete `planning-drift`, und die Zeile wurde in einem eigenen Commit nachgezogen. Der `git mv`
`in-progress/ → done/` dieser Closure macht ihn in der Gegenrichtung falsch — `in-progress/` trägt
danach keinen `slice-*.md` mehr, der Marker muss wieder stehen. Beide Male zieht ihn ein Commit
**nach** dem Move nach, denn der Move selbst ist rein; `make slice-mv` zieht Pfade nach und keine
Zustandssätze, und welcher Schritt das Feld setzt, schreibt kein Artefakt vor, das der bewegende
Lauf liest.
