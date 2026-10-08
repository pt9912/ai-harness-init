#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestFeldliste_KennzeichnungNenntGenauDieFaelleDerSpezifikation
#
# DIE FELDLISTE SAGT DIE KENNZEICHNUNG WIEDER JEDEM PFLICHTFELD OHNE QUELLWERT ZU, statt
# die abschliessende Fall-Menge von SPEC-087 (spec/spezifikation.md §5) zu nennen. Im
# Haupt-Kontext stehen `agent`, `agent_type`, `tool_use_id` und `event` als `""`; die
# allgemeine Zusage erklaert diese Werte zum Defekt.
set -euo pipefail
sed -i 's@Die Kennzeichnung \*nicht bekannt\* tragen abschließend diese Felder:@Ein Pflichtfeld, dessen Wert die Quelle nicht liefert, trägt die Kennzeichnung, etwa:@' internal/span/fieldlist.go
