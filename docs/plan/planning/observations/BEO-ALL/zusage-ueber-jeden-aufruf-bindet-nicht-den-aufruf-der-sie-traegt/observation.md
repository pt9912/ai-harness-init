# Zusage über „jeden" Aufruf bindet nicht den Aufruf, der sie trägt

**Sub-Area:** `*` (gesamtes Repo)

Ein `bats`-Fall hält die Zusage über ein Merkmal **eines bestimmten** Aufrufs — hier: der Schreibaufruf trägt
den Token-Header — mit einer Assertion über **alle** protokollierten Aufrufe: jede Kopfdatei, die der Stub sieht,
trägt Modus 0600 und den Bearer. Die Lese-Aufrufe erfüllen die Assertion; die Schwächung, die das Merkmal am
gemeinten Aufruf entfernt, färbt keinen Fall. Der Fall ist grün und die Zusage ungebunden, und am Fall allein ist
es nicht ablesbar, weil sein Name die Zusage nennt. Die Fehlerrichtung ist *die Zusage ist gebunden*.

## Benannt, nicht gezählt

[`weite-assertion-verdeckt-die-bindung-der-engen`](../weite-assertion-verdeckt-die-bindung-der-engen/observation.md)
hat eine andere Fehlerrichtung: dort färbt die weite Assertion die Mutation rot, und die enge ist nur nicht mehr
einzeln ablesbar; hier färbt **nichts**, die Schwächung überlebt die Suite.
