# Mutations-Fall deckt den lauten statt den stillen Pfad

**Sub-Area:** `*` (gesamtes Repo)

Ein Fall in `test/mutations/` mutiert eine Stelle, an der der Gate ohnehin fail-closed fällt, und
gilt damit als bestanden, während die Änderungen daneben, die den Gate **still** grün lassen,
keinen Fall tragen — die Zusicherung, die sie einzeln hält, ist nach der Feststellung des Repos
*„wer keinen Fall in `test/mutations/` hat, ist unbewacht"* ungedeckt. Die Fehlerrichtung ist
*der Wächter ist gedeckt*: Der Fall-Satz meldet grün und misst dabei die laute Hälfte.

Die Nachbarklasse
[`mutations-fall-zeigt-auf-falsche-datei`](../mutations-fall-zeigt-auf-falsche-datei/observation.md)
ist eine andere: dort trifft der Fall nach einem Umzug gar nichts mehr; hier trifft er, nur die
falsche Stelle.
