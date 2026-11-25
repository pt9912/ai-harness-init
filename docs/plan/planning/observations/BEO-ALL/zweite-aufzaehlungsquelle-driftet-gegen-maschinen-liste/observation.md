# Eine zweite Aufzählungsquelle driftet gegen die Maschinen-Liste

**Sub-Area:** `*` (gesamtes Repo)

Eine hand-geführte Aufzählung in Prosa dupliziert eine maschinenlesbare Menge des
Bestands — hier die Modul-Aufzählung der `docs-check`-Zeile des Gate-Index gegen die
`modules:`-Zeile der `.d-check.yml`. Kein Wächter hält die Prosa-Seite an die
Maschinen-Seite, und jede Änderung an der Maschinen-Seite erzeugt dieselbe Fundmenge
neu („Die nächste Änderung an `modules:` erzeugt dieselbe Fundmenge neu"). Die
gehobene Setzung ist die Beseitigung der zweiten Quelle — die Zelle führt die Menge
als abgeleitete Live-Liste über `grep` — statt der Erweiterung um den neuen Eintrag.

Abgrenzung zur Nachbarklasse
[`vertragliche-aufzaehlung-trifft-den-bestand-nicht`](../vertragliche-aufzaehlung-trifft-den-bestand-nicht/observation.md):
dort steht die Aufzählung in Rang 1 und zählt kleiner als der Code-Bestand; hier ist
die zweite Quelle ein Duplikat einer geschlossenen Maschinen-Menge in der Prosa des
Gate-Index, und die Hebung ist die Abschaffung der Duplikat-Quelle.
