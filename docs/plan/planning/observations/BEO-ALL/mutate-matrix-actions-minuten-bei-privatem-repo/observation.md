# Erhöhte Actions-Minuten des Mutate-Matrix-Laufs bei privatem Repo

**Sub-Area:** * (gesamtes Repo)

Der `mutate`-Nacht-Workflow fährt seit der Matrix-Umstellung mehrere parallele Shard-Jobs statt
eines Einzel-Jobs. Auf einem öffentlichen GitHub-Repo ist das kostenfrei; wechselt das Repo auf
privat, zählt jeder Shard einzeln gegen das Actions-Minuten-Kontingent, und die Gesamtkosten des
Nacht-Laufs wären gegenüber dem früheren Einzel-Job neu zu bewerten.
