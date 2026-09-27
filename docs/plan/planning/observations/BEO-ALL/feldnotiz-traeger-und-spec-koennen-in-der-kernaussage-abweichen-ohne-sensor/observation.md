# Feldnotiz im Träger und Spec §5 können in der Kernaussage abweichen, ohne dass ein Sensor es sieht

**Sub-Area:** `*` (gesamtes Repo)

`internal/span/fieldlist.go` (`SchemaNotes()`) und `spec/spezifikation.md` §5 stellen je Feld eine
Incident-Frage — bewusst in zwei verschiedenen Registern (Adopter-terse im Träger, Rang-2-normativ
in §5) und sollen das bleiben. Sie sollen aber in der **Substanz** (Kernaussage je Feld)
übereinstimmen, dürfen in Form und Detailgrad legitim divergieren — und kein Sensor hält auch nur
die **Existenz**-Achse zwischen beiden. Das unterscheidet den Fall von
[`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md):
dort **sollen** zwei Fassungen (Dogfood-Skript vs. Emissions-Vorlage) byte- bzw.
verhaltensidentisch sein; hier dürfen zwei Fassungen (Adopter-Text vs. Rang-2-Text) in Wortlaut und
Detailgrad divergieren, sollen aber dieselbe Kernaussage tragen.
