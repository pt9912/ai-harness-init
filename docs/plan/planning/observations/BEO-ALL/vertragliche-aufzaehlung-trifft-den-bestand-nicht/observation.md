# Vertragliche Aufzählung trifft den Bestand nicht

**Sub-Area:** `*` (gesamtes Repo)

Eine Aufzählung in Rang 1 zählt die Instanzen einer Eigenschaft kleiner, als der Code-Bestand sie
trägt — hier die Aufzählung der wiederkehrenden Vorlagen in
[`LH-FA-02`](../../../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) gegen
die Menge in `isRecurring`. Kein Wächter hält Rang 1 an den Bestand — ein Slice kann Rang 1 nicht
schreiben —, die Differenz bleibt bestehen, bis ein Change Request sie einholt. Der
Dispositions-Wächter hängt bewusst an der Eigenschaft gegen den vendored Satz, nicht an der
Aufzählung ([`ADR-0057`](../../../../../plan/adr/0057-wiederkehrende-vorlagen-menge-bindet-als-eigenschaft.md)
Festlegung 2).

## Benannt, nicht gezählt

Die erste Messung der Differenz liegt in der Ausgangsmessung des Slice-Plans und in
[`ADR-0057`](../../../../../plan/adr/0057-wiederkehrende-vorlagen-menge-bindet-als-eigenschaft.md) —
beide ohne abgeschlossenen Vorgang, beides bewegt keinen Zähler.