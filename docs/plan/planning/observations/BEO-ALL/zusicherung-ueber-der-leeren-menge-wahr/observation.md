# Zusicherung über der leeren Menge wahr

**Sub-Area:** `*` (gesamtes Repo)

Eine Zusicherung prüft eine **Negation** über einer Menge, die sie sich selbst besorgt — fällt die
Menge weg, greift die Negation, und die Zusicherung ist grün, ohne etwas gemessen zu haben. Die
Fehlerrichtung ist *die Eigenschaft gilt*, wo in Wahrheit nichts vorlag; sichtbar wird sie erst,
wenn jemand die Bezugsmenge entfernt statt ihren Inhalt zu ändern.

Der Ausweg steht im Bestand vorgemacht: `test/archiv-stub-vorlagen.bats` hält seine Extraktion mit
einem **zweiten** Fall gegen ihre eigene Bezugsmenge, statt die Quantifizierung über der leeren
Menge stehen zu lassen.
