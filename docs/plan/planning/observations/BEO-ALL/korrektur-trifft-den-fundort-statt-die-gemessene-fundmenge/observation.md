# Korrektur trifft den Fundort statt die gemessene Fundmenge

**Sub-Area:** `*` (gesamtes Repo)

Ein Report nennt **Fundorte**; die Behebung behandelt sie als **Fundmenge** und zieht ihre Stellen
über das Wortmuster des Befundes statt über die Eigenschaft, um die es geht. Die nächste Runde
findet dieselbe Aussage an einer Stelle, die das Muster nicht traf — oder findet an der einen
gezogenen Stelle eine **neue** ungemessene Behauptung. Die Schleife verlängert sich um eine Runde,
und sie wiederholt sich, bis jemand die Klasse statt der Stellen fegt.

Die Fehlerrichtung ist *die Klasse ist kleiner, als sie ist*: Sie lässt einen Fix vollständig
aussehen, obwohl er es nicht ist, und erzeugt dabei kein Signal — kein Gate misst die Ausdehnung
einer Aussage.

## Benannt, nicht gezählt

Die Nachbarklasse
[`reparatur-vorgabe-ohne-messung-des-vorgeschriebenen-artefakts`](../reparatur-vorgabe-ohne-messung-des-vorgeschriebenen-artefakts/observation.md)
ist eine andere: Dort schreibt die **prüfende** Rolle einen ungemessenen Weg vor, hier
unterschätzt die **behebende** Rolle die Ausdehnung der Klasse. Gleiches Symptom, andere Ursache,
andere Seite.

Ebenfalls nicht dieselbe:
[`extensionale-zahl-unterschreitet-die-eigene-fundmenge`](../extensionale-zahl-unterschreitet-die-eigene-fundmenge/observation.md)
— dort beziffert ein Text seine eigene Aufzählung zu klein; hier wird gar nicht beziffert, sondern
ein Wortmuster für die Menge gehalten.
