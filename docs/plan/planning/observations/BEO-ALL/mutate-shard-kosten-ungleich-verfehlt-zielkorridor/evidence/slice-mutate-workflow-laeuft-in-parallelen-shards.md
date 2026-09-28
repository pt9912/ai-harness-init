**Vorgang:** slice-mutate-workflow-laeuft-in-parallelen-shards
**Fund:** Erster realer Matrix-Lauf (`workflow_dispatch`, Run `36375725927`, 2026-09-28):
Shard-Laufzeiten zwischen 21 und 37 Minuten bei einer `full-smoke`-Verteilung von 6/4/5/2/2 über
5 Shards (Index-Modulo-Round-Robin über 484 Fälle); der volle Fall-Satz brauchte ~36 Minuten
Wall-Clock statt der im Plan angepeilten ~20–25 Minuten. Plan-Risiken 1 (ungleiche Fall-Kosten)
und 2 (Startwert 5 trifft Zielkorridor evtl. nicht) sind derselbe, jetzt real gemessene Befund.
