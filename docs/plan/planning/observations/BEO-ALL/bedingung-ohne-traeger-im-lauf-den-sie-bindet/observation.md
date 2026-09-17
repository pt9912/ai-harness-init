# Bedingung ohne Träger im Lauf, den sie bindet

**Sub-Area:** `*` (gesamtes Repo)

Eine Begründung hängt an einer Bedingung, die ein späterer Lauf erfüllen muss — eine Prüfung je
Schritt, eine Reihenfolge —, und die Bedingung steht nur in Plan-Dateien, die dieser Lauf nicht als
Eingang liest. Der Lauf, der sie tragen soll, ist über sie nicht instruiert. Die Fehlerrichtung ist
*die Bedingung gilt*.

Zwei Nachbarklassen decken den Fall nicht.
[`waechter-abdeckung-haengt-an-uninstruierter-konvention`](../waechter-abdeckung-haengt-an-uninstruierter-konvention/observation.md)
setzt einen Wächter voraus, den eine nicht instruierte Aufrufform nicht erreicht; hier ist die
Bedingung selbst die Absicherung, und kein Wächter steht hinter ihr.
[`uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md)
fehlt das Artefakt ganz; hier existiert es, steht aber nicht im Eingang des gebundenen Laufs.
