# Pin-Sprung macht die Test-Eingabe gleich dem Default und die Zusage unsichtbar

**Sub-Area:** `*` (gesamtes Repo)

Ein Test hält eine Zusage (hier: die Version wird durchgereicht, nicht der Default eingesetzt), indem er eine explizite Eingabe übergibt, die zufällig dem gepinnten Default gleicht. Ein Pin-Sprung zieht Eingabe und Default auf denselben Wert; die Mutation „Default statt Eingabe" färbt den Test nicht mehr, und `make gates` meldet nichts. Gefangen hat es nur die CI-Mutations-Probe.
