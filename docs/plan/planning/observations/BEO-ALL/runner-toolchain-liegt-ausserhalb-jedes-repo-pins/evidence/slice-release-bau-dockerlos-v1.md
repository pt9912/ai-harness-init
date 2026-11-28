**Vorgang:** slice-release-bau-dockerlos-v1
**Fund:** Der `artifacts`-Job des workflow_dispatch-Laufs 46155129162 kompiliert
host-nativ am Runner; die Go-Fassung kommt aus dem `GO_VERSION`-Pin des
`Makefile` über `make ci-runner-setup` (Mischform je [MR-098](../../../../../../../harness/conventions.md#mr-098--die-umgebungs-zusage-trägt-mischform-die-dogfood-gates-und-lab-läufer-fahren-am-host), am Pin geprüft
je `pinsync`). Der Lauf belegt die Gelingens-Seite — über die Umgebungs-Pflicht
der Runner-Images urteilt er nicht: kein Pin und kein Sensor hält das
Runner-Image selbst. Der Runner-Rest aus §6 des Slices trägt darum weiter
offen; Träger sind die Re-Evaluierungs-Trigger 1/2 von [ADR-0115](../../../../../adr/0115-release-bau-docker-los-in-ci.md), die Grenze
steht in dessen Festlegung 3 (Beleg: Review-Report unter
`docs/reviews/2026-11-28-slice-release-bau-dockerlos-v1.md` und §7 des Slices).
