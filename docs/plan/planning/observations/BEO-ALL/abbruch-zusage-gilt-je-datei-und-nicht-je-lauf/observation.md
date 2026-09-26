# Eine Abbruch-Zusage gilt je Datei, der Lauf lässt den Arbeitsbaum teil-geschrieben zurück

**Sub-Area:** `*` (gesamtes Repo)

Ein Werkzeug arbeitet eine Liste von Dateien ab und sagt für den Ausfall zu, es breche ab und *die Datei bleibe,
wie sie war*. Wahr ist die Zusage für die Datei, an der der Ausfall eintrat; die Dateien davor stehen
umgeschrieben und ungestaged im Arbeitsbaum. Der Test bindet die Zusage nur, weil sein Ausfall schon die erste
Datei trifft — den Ausfall an einer späteren Datei trifft er nicht. Die Fehlerrichtung ist *der abgebrochene Lauf
hinterlässt nichts*.

## Benannt, nicht gezählt

[`doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst`](../doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst/observation.md)
liegt daneben: dort misst der genannte Fall einen Ausschnitt der Eigenschaft; hier misst er die Eigenschaft je
Datei genau, und die Zusage ist für den Lauf zu weit gefasst.
[`zusage-nennt-zwei-kanten-der-sensor-deckt-eine`](../zusage-nennt-zwei-kanten-der-sensor-deckt-eine/observation.md)
trennt *vor* und *nach* dem Vorgang; hier trennt die Grenze die scheiternde Datei von den bereits geschriebenen.
