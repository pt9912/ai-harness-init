# Mutations-Fall an Zeilennummer statt an Muster verankert

**Sub-Area:** `*` (gesamtes Repo)

Der `sed`-Anker eines Mutations-Falls adressiert per **Zeilennummer**. Jede Zeile, die im
geprüften Code darüber hinzukommt, verschiebt die Adresse, und der Fall hat danach zwei Ausgänge,
von denen keiner die Sache trifft: Eine kleine Verschiebung macht das `sed` zum No-op, und der
Treiber meldet fail-closed *„Mutation hat nicht gegriffen … Patch veraltet?"*; eine Verschiebung,
die zufällig auf eine Kommentarzeile trifft, mutiert Text ohne Wirkung, und der Treiber meldet
*„… hat keine Zaehne mehr"* über einem Wächter, der seine Zähne hat. Der zweite Ausgang ist der
teure — rot mit einer Begründung, die auf diesen Treffer nicht zutrifft.

Die Fehlerrichtung ist *der Fall zeigt auf die Stelle*: Er liest sich verankert, und die
Verankerung hält nur bis zur nächsten Zeile darüber.

Die Nachbarklasse
[`mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md)
teilt den ersten Ausgang und nicht den zweiten: Dort zitiert der Anker den **Wortlaut** einer
Zeile, und eine Änderung an genau dieser Zeile entwaffnet ihn — treffen kann er danach nichts
anderes. Ein Zeilen-Anker trifft weiter, nur eben etwas anderes.
