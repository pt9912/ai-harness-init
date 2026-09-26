# Eine Regel verlangt einen Beleg-Inhalt, den die Ausgabe des Werkzeugs nicht liefert

**Sub-Area:** `*` (gesamtes Repo)

Eine Regel im Sensor-Doc nennt als Bedingung einen Inhalt der Werkzeug-Ausgabe — hier den
Prüfgegenstand-Schlüssel, den **beide** Läufe nennen müssen —, und die Ausgabe des Werkzeugs trägt ihn
nur in einer der Formen, auf die die Regel zielt: Ein voller Lauf mit Befund druckte ihn nicht. Die
Bedingung ist dann für den Lauf, den sie betrifft, nicht erfüllbar; wer die Regel liest, zieht die
Aussage nie oder beschafft den Inhalt außerhalb der Regel. Die Fehlerrichtung ist *die Regel ist
anwendbar*, und sie ist strenger, als sie klingt — die sichere Richtung, aber die frühere Praxis, die
sie tragen soll, ist mit ihr nicht durchführbar.

## Benannt, nicht gezählt

[`bedingung-ohne-traeger-im-lauf-den-sie-bindet`](../bedingung-ohne-traeger-im-lauf-den-sie-bindet/observation.md)
hat einen anderen Ort der Lücke: dort steht die Bedingung in Dateien, die der Lauf nicht als Eingang
liest; hier liest der Leser die Regel, und das fehlende Stück liegt in der **Ausgabe** des Werkzeugs,
über das sie spricht.
