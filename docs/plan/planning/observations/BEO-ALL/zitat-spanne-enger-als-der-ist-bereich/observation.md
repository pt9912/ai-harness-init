# Zitat-Spanne enger als der Ist-Bereich

**Sub-Area:** `*` (gesamtes Repo)

Ein Slice-Plan zitiert eine Form-Quelle der Vorlage mit einer **Fundstellen-Spanne**, die enger
ist als der Abschnitt in der Vorlage tatsächlich läuft — die zwei Zeilen der Zitier-Stelle statt
des mehrzeiligen Blocks. Kein Verweis bricht (kein Anker hängt am Zitat), aber ein Leser, der mit
der genannten Spanne prüft, sieht nur einen Teil des Trägers und hält die Prüfung für
vollständig. Der Griff ist die Spannen-Stichprobe vor dem Zitat — `sed -n` je genannter Spanne,
`diff`/`cmp` der Blöcke gegen die Zielform —, nicht eine nachgetragene Korrektur der Angabe an
bereits weiterverlinkten Wegen.
