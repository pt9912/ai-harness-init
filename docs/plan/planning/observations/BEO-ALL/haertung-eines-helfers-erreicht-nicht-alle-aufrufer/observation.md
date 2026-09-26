# Die Härtung eines gemeinsamen Helfers erreicht nicht alle seine Aufrufer

**Sub-Area:** `*` (gesamtes Repo)

Ein Helfer, den mehrere Funktionen aufrufen, wird gegen das stille Weiterlaufen nach einem Fehler gehärtet und
meldet den Fehler jetzt als Status. Ein Teil der Aufrufer reicht den Status nicht weiter: sie melden bei Ausfall
Erfolg samt einem Zähler, der Ersetzungen nennt, die nicht stattfanden. Eine zweite Fassung desselben Skripts trägt
den Helfer in der alten Form, und die Kopplung zwischen den Fassungen vergleicht nur die Funktionen ihrer
Kern-Liste, nicht den Helfer daneben. Die Fehlerrichtung ist *die Härtung gilt für jede Stelle, die den Helfer
ruft*.

## Benannt, nicht gezählt

Ein Rückgabe-Zweig der Härtung, den kein Fall rot färbt, weil eine Nachbarzeile denselben Status zufällig liefert,
ist eine andere Klasse (Zweig ohne eigenen Zahn) und keine Instanz dieser.
[`fehlerabbruch-durch-aufruf-im-oder-kontext-entwaffnet`](../fehlerabbruch-durch-aufruf-im-oder-kontext-entwaffnet/observation.md)
ist die Ursache, die die Härtung nötig machte; hier ist es ihre Reichweite.
