# Emittierte Neutralisierung greift am vendorten Stand nicht

**Sub-Area:** `*` (gesamtes Repo)

`NeutralizeRoadmap` und `roadmapDoneLink` (`internal/emit/templates.go`) ersetzen einen Wortlaut der
Roadmap-Vorlage (`welle-NN-results.md`), den die vendorte Vorlage nicht mehr führt (sie führt
`<welle-id>-results.md`); der Ersatz trifft im erzeugten Ziel nichts, und `TestNeutralizeRoadmap`
hält eine Fixture mit dem alten Wortlaut. Ein Wächter, der über einer nachgebauten Eingabe grün
bleibt, während die reale Quelle den Marker nicht mehr trägt, deckt toten Code.
