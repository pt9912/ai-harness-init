**Vorgang:** slice-release-bau-dockerlos-v1
**Fund:** Die `make build`-Sensor-Zelle in `harness/README.md` trug den
Ist-Stand "Release-Bau bleibt docker-getrieben" — gegen die mit [ADR-0115](../../../../../adr/0115-release-bau-docker-los-in-ci.md)
umgestellte host-Form (`make release-artifacts-host`, Liefer-Punkt b). Der
Slice änderte die Zelle (Liefer-Punkt c, Commit `bdf5c6cd`); die
DoD-c-Messung `grep -n 'docker-getrieben\|Docker-only' harness/README.md
harness/sensors/artifact-host.md docs/user/releasing.md` meldet 0 Resttreffer.
Kein Sensor liest den Wortlaut einer Zelle gegen den Stand, den sie
beschreibt — die Klasse kann weiter auftreten; Beleg: Review-Report
`docs/reviews/2026-11-28-slice-release-bau-dockerlos-v1.md`
(§Negativbefunde, DoD-c-Messung).
