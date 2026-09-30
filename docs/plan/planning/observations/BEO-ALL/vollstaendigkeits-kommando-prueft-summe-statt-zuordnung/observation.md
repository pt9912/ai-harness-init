# Vollständigkeits-Kommando prüft Summe statt Zuordnung

**Sub-Area:** `*` (gesamtes Repo)

Das Kommando, das eine Vollständigkeits-Zusage belegt, hat selbst Blindstellen: eine Sammelzeile
verdeckt Namen, die eine Namens-Differenz sonst melden müsste, und eine Summe deckt keine
Zuordnung — Bytes oder Zeilen zwischen zwei Einheiten zu verschieben lässt sie grün. Gegenstand
ist damit das **Beleg-Kommando** auf der Ebene *Summe/Namensmenge gegen Zuordnung*; die Klasse
[`vollstaendigkeits-zusage-misst-falsche-ebene`](../vollstaendigkeits-zusage-misst-falsche-ebene/observation.md)
trifft dagegen die **Zusage** über ein Delta auf der Ebene *Datei gegen Hunk*.
