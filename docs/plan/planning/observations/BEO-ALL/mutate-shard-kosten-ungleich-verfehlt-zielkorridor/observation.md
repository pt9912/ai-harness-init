# Matrix-Sharding: ungleiche Fall-Kosten verfehlen den Zielkorridor

**Sub-Area:** * (gesamtes Repo)

Der `mutate`-Nacht-Workflow verteilt die 484 Mutations-Fälle per deterministischem
Index-Modulo-Round-Robin auf gleich große Shards. Die teuren `full-smoke`-Fälle häufen sich dabei
zufällig ungleich zwischen den Shards, wodurch einzelne Shards deutlich länger laufen als andere
und der volle Matrix-Lauf insgesamt außerhalb eines vorab gesetzten Zielkorridors landen kann.
