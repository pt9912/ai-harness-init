# Buchung wiederholt die Folgerung ihrer Norm

**Sub-Area:** `*` (gesamtes Repo)

Ein lebendes Register bucht eine Entscheidung — Ort, Ziel-Tag, Datum, Zeiger — und schreibt
daneben die **Folgerung**, die die Entscheidung selbst trägt. Die Aussage steht danach zweifach:
in ihrer normativen Quelle und in der Buchung, die auf sie zeigt. Die zweite Fassung ist aus der
ersten ableitbar, und genau darum ist sie teuer: Sie veraltet still, sobald sich die Quelle oder
die Aufzählung unter ihr bewegt, und kein Modul aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) hält zwei Fassungen derselben Aussage
gegeneinander.

Die Fehlerrichtung ist *die Buchung ist der Zustand*: Wer sie liest, nimmt die abgeleitete
Folgerung für gebucht statt für abgeleitet — und wer die Quelle ändert, ändert die Buchung nicht
mit.

Zwei Nachbarn teilen die Richtung und nicht den Gegenstand:
[`zusammenfassung-staerker-als-ihre-quelle`](../zusammenfassung-staerker-als-ihre-quelle/observation.md)
trifft die Zusammenfassung, die **mehr** zusagt als ihre Quelle — dort ist die Kopie falsch, hier
ist sie treu —, und
[`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
die Zusage, die eine **geänderte** Ableitung überlebt — dort bewegt sich die Ableitung, hier steht
die Kopie von Anfang an daneben.
