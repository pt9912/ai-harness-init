# Wächter misst die Fixture statt der realen Quelle

**Sub-Area:** `*` (gesamtes Repo)

Ein Wächter in `make gates` prüft seine Regel über einer **nachgebauten** Eingabe, weil die reale
Quelle für ihn nicht erreichbar ist — der Docker-Build-Kontext der Test-Stufe schließt sie aus, oder
sie entsteht erst zur Laufzeit. Die Regel ist damit über der Fixture bewiesen und über dem
Gegenstand nur behauptet; ob beide dieselbe Form tragen, hält bestenfalls ein zweiter, schwächerer
Sensor.

Die Fehlerrichtung ist *die Regel ist gedeckt*: Der Wächter ist grün, sein Fall-Satz ist
vollständig, und trotzdem sagt kein Lauf etwas darüber, ob die Regel das trifft, was ausgeliefert
wird. Besonders teuer wird die Klasse, wenn die reale Quelle **Fremdtext** ist und bei jedem
Re-Baseline vollständig getauscht wird: Dann altert die Fixture gegen einen Gegenstand, den
niemand beobachtet.

Die Nachbarklasse
[`zusicherung-ueber-der-leeren-menge-wahr`](../zusicherung-ueber-der-leeren-menge-wahr/observation.md)
deckt den Fall nicht: dort ist die Bezugsmenge leer, hier ist sie gefüllt — nur mit dem falschen
Inhalt.
