**Vorgang:** slice-127
**Fund:** Der Anspruchs-Commit landete **nach** der Arbeit, und zwischen beiden lag der volle
Liefer-Diff des Slice. Gemessen an der Commit-Folge des Vorgangs
(`git log --format='%h %ad %s' --date=format:'%H:%M:%S' 6a2e0d5f..0a20eff6 --reverse`): `44427bec`
*„Rolle Implementer: slice-127 — ADR-Immutabilitaet bekommt ihren Sensor"* um 12:01:28, danach
`a847bfb8` *„slice-mv: … next/ -> in-progress/ (reiner Move)"* um 12:01:35. Der Ruhe-Marker der
Roadmap stand damit über die Arbeit hinweg auf *„Nichts in Arbeit."*, und `planning-drift` stand
danach über zwei Commits (`a847bfb8`, `fcd146b1`) auf dem Hauptzweig, bis `0a20eff6` den Marker
nachzog.

**Die zweite Hälfte ist die teurere, und sie ist der Grund für diesen Beleg:** Der Commit mit der
Arbeit ist **grün**. `44427bec` trägt die vollständige Lieferung eines Slice auf dem Hauptzweig,
während `in-progress/` leer ist und die Roadmap Ruhe meldet — das Modul `planning` hält den
Ruhe-Marker gegen das Verzeichnis, und beide waren miteinander konsistent. Es hält **nicht** Arbeit
gegen Anspruch. Der Verstoß hinterlässt am Ort der Arbeit keine Spur, an der ein Wächter ansetzen
könnte; laut wird nur der Marker-Nachlauf, also die Folge, nicht die Ursache.
