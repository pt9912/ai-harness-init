**Vorgang:** slice-200
**Fund:** Das neue Ziel `make vendor-baseline` legt den vendored Baum aus dem verifizierten
Release-Asset an und macht damit den **Vorgang** reproduzierbar; die von
[`harness/conventions.md`](../../../../../../../harness/conventions.md) §Adoptierte
Konventions-Quellen benannte Lücke *„Asset → vendored Baum hält nichts"* betrifft den **Bestand**
und bleibt unverändert offen — der heute liegende Baum ist dadurch nicht als asset-stämmig belegt.
Die falsche Aussage ist in den Artefakten dieses Slice **nicht** gefallen: Die Konventions-Zeile
steht unverändert, und [`harness/README.md`](../../../../../../../harness/README.md) ordnet das Ziel
ausdrücklich als *kein Gate* ein. Gehalten wird die Unterscheidung damit von zwei Prosa-Sätzen und
von keinem Sensor.
