#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestFeldliste_OhneMarkdownLink
#
# HAENGT EINEN MARKDOWN-LINK VOR limitStore: die emittierte Feldliste liegt im geprueften
# Doku-Bereich des Ziels und ist KONVERGENT — ein toter relativer Verweis darin faerbte
# das Doku-Gate des Adopters rot, ohne dass er ihn heilen koennte (ein Re-Lauf setzt die
# Datei zurueck). Diese Mutation fuegt genau die verbotene Form `](` ein.
set -euo pipefail
sed -i 's@const limitStore = "\*\*Über den Bestand@const limitStore = "Siehe [Details](https://example.invalid). **Über den Bestand@' internal/span/fieldlist.go
