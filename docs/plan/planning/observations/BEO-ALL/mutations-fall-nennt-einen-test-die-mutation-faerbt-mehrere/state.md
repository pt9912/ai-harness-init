**Stand:** offen

Unterhalb der Schwelle (2×,
`ls docs/plan/planning/observations/BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere/evidence/*.md | wc -l`,
gelesen 2026-09-27, keine Erwartung); `offen` ist hier der Normalzustand und kein Ausgang. Gemeldet wird die Klasse von keinem Sensor: `make mutate` verlangt, dass der `# expect:`-Name in der
roten Ausgabe steht (Meldung *„rot, aber '<expect>' faellt nicht — falscher Grund"*,
[`harness/tools/mutate.sh`](../../../../../../harness/tools/mutate.sh)), und prüft nicht, ob er der
einzige rote Test ist. Träger ist die Gegenprobe, die bei jeder Mutation die **ganze** rote Menge
abschwächt statt des benannten Tests.
