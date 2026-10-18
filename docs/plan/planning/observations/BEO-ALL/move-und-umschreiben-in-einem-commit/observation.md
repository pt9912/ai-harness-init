# Umbenennen und Umschreiben einer Datei in einem Commit

**Sub-Area:** `*` (gesamtes Repo)

Eine Datei wird umbenannt und im selben Commit inhaltlich geändert; git zeigt `A` und `D` statt eines
Renames, die Historie der Datei ist nicht mehr verfolgbar
([`AGENTS.md`](../../../../../../AGENTS.md) §3.3). Den Zuschnitt hält für `make slice-mv` die Stufe
`full-smoke` (Move-Commit ohne Inhaltsänderung); für jeden anderen Umbau, etwa den Umbau eines
Mutations-Falls, liest ihn kein Sensor.
