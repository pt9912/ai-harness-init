# Gates-Lauf erschöpft Runner-Ressourcen, bevor docs-check fährt

**Sub-Area:** `*` (gesamtes Repo)

Der CI-Job `gates` bricht unter Runner-Ressourcenerschöpfung in
`harness/tools/gates-keys.sh` ab — `fork: retry: Resource temporarily
unavailable`, danach `make: *** Terminated` — und `docs-check` fährt in dem
Job nie. Die Tier-2-Maschinerie stammt aus `slice-gates-pruefgegenstand-stempel-v1`
(wellenlos, geschlossen); der Befund trägt gegen ihn. Zwei Nachbarklassen mit
derselben Wirkung, anderer Ort: `gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last`
(mutate-Grün-Vorlauf unter Runner-Last) und `sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt`
(Registry/Docker-Daemon als Ursache, nicht das Fork-Limit des Runners).

## Benannt, nicht gezählt

Die vorgefundene Erst-Signatur (Lauf 45939443193, 2026-11-27T04:21) trägt auf
denselben Vorgang wie der Beleg unten — sie ist eine wiederholte Meldung,
kein zweites Auftreten; die Wiederholung am HEAD-Stand (Lauf 45944570095) ist
in der Beleg-Datei vermerkt.
