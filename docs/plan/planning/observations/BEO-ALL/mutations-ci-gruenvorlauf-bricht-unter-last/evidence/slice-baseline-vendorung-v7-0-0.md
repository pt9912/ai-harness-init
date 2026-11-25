**Vorgang:** slice-baseline-vendorung-v7-0-0

**Fund:** Der Grün-Vorlauf der Mutations-CI-Probe brach an einer **geplant
roten** `test-bats`-Fläche, bevor ein Fall urteilte: alle zehn Shard-Jobs
(0–9, Run 45666751330, geprüfter Commit `6a80cf3d`) kehrten mit `rc=2` ohne
eine `mutate: ok`-Zeile zurück; je Shard brachen die vier Worker fail-closed
im Grün-Vorlauf ab (`ABBRUCH — make test-bats ist in SEINER Kopie ohne
Mutation rot`), weil der Vorlauf in ihrer Kopie die geplant-roten
C2-Fixtur-Fälle (17/19/20/105–108) traf. 0 Fall-Urteile in allen drei Läufen
(`45655913161`, `45661467791`, `45666751330`); der `ergebnis`-Schritt las die
Shard-Logs richtig („kein Ergebnis im Log“ über alle 65) — die Bruchstelle
ist die Vorlauf-Schicht, nicht der Fall.

**Grenze:** Diese Beleglage bricht nicht unter infrastruktureller Last,
sondern an einer absichtlich roten Fläche des Zwischenstands (Cluster C2,
Template-Renames) — sie teilt mit dem ersten Beleg die Klasse
(die Vorlauf-Schicht verliert, bevor ein Fall urteilt; „die Vorlauf-Schicht
verliert, nicht der Fall“) und ist hier als zweiter Beleg neben ihm gezählt.
Träger der Heilung ist der Zustand der Fläche (`test-bats` grün als
Vorbedingung jedes Fall-Urteils), nicht der Treiber; bis dahin ist die Probe
unurteilbar und der Fall-Beleg bleibt der Lokallauf-Differenz
(`make mutate-greift` Anker-Treffer) schuldig.

Beleg-Anker:
[`docs/reviews/2026-11-25-slice-baseline-vendorung-v7-0-0.md`](../../../../../../reviews/2026-11-25-slice-baseline-vendorung-v7-0-0.md)
(Shard-Artefakte des 3. Laufs, Findings F-1/F-2/F-3).
