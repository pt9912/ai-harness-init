**Stand:** offen

Die Lücke ist in [`harness/conventions.md`](../../../../../../harness/conventions.md)
§Adoptierte Konventions-Quellen benannt — *„Asset → vendored Baum hält nichts"* —, ein Sensor
dafür besteht nicht. Der **Vorgang** hat seinen Träger: `make vendor-baseline` legt den Baum aus
dem verifizierten Asset an, über dieselbe Fähigkeit in `internal/fetch/baseline.go`, die zuvor nur
der Init-Pfad für Ziel-Repos rief. Er stellt her und prüft nicht; über die Herkunft des
**vorhandenen** Baums sagt er nichts, und diese Hälfte trägt
[`traeger-fuer-den-vorgang-belegt-den-bestand-nicht`](../traeger-fuer-den-vorgang-belegt-den-bestand-nicht/observation.md).
