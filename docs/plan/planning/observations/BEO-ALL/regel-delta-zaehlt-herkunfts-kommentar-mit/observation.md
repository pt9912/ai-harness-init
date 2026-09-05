# Regel-Delta über vendored Bäume zählt den Herkunfts-Kommentar mit

**Sub-Area:** `*` (gesamtes Repo)

Ein Zeilen-Diff über zwei **vendored** Bäume wird als Regel-Delta gelesen, obwohl er den
Herkunfts-Kommentar `<!-- Quelle: … -->` mitzählt, den das Vendoring je Datei setzt und dessen
Ziel-Form zwischen zwei Bäumen wandert; die Fehlerrichtung ist *geändert* statt *unverändert* —
spiegelbildlich zu `BEO-019`, das die Gegenrichtung führt.
