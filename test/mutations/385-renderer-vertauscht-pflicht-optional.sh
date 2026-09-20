#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestFieldList_TabelleTraegtJedesErfassteFeldEinmal
#
# VERTAUSCHT DIE PFLICHT/OPTIONAL-SPALTE IM RENDERER: RenderFieldList setzt "Pflicht"
# genau dann, wenn ein Feld NICHT erfasst-pflicht ist — die Tabelle sagt dann fuer jedes
# Feld das Gegenteil dessen, was der Draht traegt. TestFeldliste_LiegtVerbatimImZiel
# faengt das NICHT (beide Seiten lesen dieselbe mutierte Funktion); dieser Waechter
# vergleicht gegen die REFLEKTIERTEN SchemaFields() und faellt.
set -euo pipefail
sed -i 's/if f\.Required {/if !f.Required {/' internal/span/fieldlist.go
