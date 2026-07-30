#!/usr/bin/env bash
# files: internal/span/response.go
# expect: TestResolvedModelIsStructurallyBounded
#
# DIE SCHRANKE UM `model_version` KUERZT, STATT ZU VERWERFEN: ein `resolvedModel` ueber
# der Laengen-Schranke wird auf 64 Byte abgeschnitten und dann weiterverarbeitet, statt
# das Feld ganz wegzulassen.
#
# WARUM GENAU DIESE MUTATION und nicht „Schranke weg": der Kommentar an `modelVersion`
# sagt VERWORFEN WIRD GANZ, NICHT GEKUERZT, und begruendet es — 64 Byte eines
# Geheimnisses sind auch 64 Byte fremden Inhalts, und ein verstuemmeltes Praefix ist ein
# falsches Protokoll, wo „unbekannt" das ehrliche ist (ADR-0011 Festlegung 2, „kein Byte
# fremden Inhalts"). Ein Fall, der die Schranke ganz entfernt, belegt nur, dass ueberhaupt
# eine da ist. Dieser hier belegt die FEINERE Zusage — und er impliziert die groebere:
# derselbe Vergleich faellt auch, wenn gar nicht mehr begrenzt wird.
#
# WARUM ES DIESEN FALL BRAUCHT: MR-018 §Bewacht berief sich bis zum 2026-07-30 fuer den
# Rot-Beleg auf einen Implementations-Bericht, den es im Repo nie gab (Review-Befund
# MEDIUM-3), und nannte den fehlenden Dauer-Sensor selbst als Luecke. Beides ist mit
# diesem Fall erledigt.
#
# ROT WIRD GENAU EINER, und zwar am Unterfall „ein Byte darueber": 65 `a` ergeben
# gekuerzt 64 `a`, erwartet ist das LEERE Feld. Die uebrigen Waechter dieser Flaeche
# fahren `claude-opus-5[1m]` (17 Byte) und bleiben unberuehrt. Damit ist „129 rot"
# gleichbedeutend mit „die Schranke verwirft, statt zu kuerzen" (Bedingung 4).
set -euo pipefail
sed -i 's@^\tif s == "" || len(s) > maxModelVersion {@\tif len(s) > maxModelVersion {\n\t\ts = s[:maxModelVersion]\n\t}\n\tif s == "" {@' internal/span/response.go
