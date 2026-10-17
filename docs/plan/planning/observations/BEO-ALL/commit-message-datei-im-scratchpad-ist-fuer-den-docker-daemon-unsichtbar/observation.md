# Commit-Message-Datei im Scratchpad ist für den Docker-Daemon unsichtbar

**Sub-Area:** `*` (gesamtes Repo)

Der Docker-Daemon sieht das Scratchpad des Agenten nicht als Mount; eine Commit-Message-Datei für
`git commit -F` liegt deshalb nur aus einem gitignorierten Pfad unter `.harness/state/` vor, nicht im
Scratchpad.
