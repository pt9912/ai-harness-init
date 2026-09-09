#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning: closure setzt kein eigenes glob (Filter bleibt der Modul-Default slice-glob)
#
# Setzt `glob: '*.md'` unter `closure:` — die verworfene Weitung auf die Welle-Ebene
# (harness/README.md: zwei Fundklassen gegen den heutigen Bestand, ueberwiegend keine fehlende
# Substanz, sondern die auf zwei Dateien verteilte Welle-Closure-Form). `docs-check` selbst
# faerbt darauf 8 von 12 Welle-Plaenen und alle 12 Welle-Ergebnisnotizen unter `done/` rot
# (harness/README.md nennt die genaue Aufschluesselung); dieser Waechter haelt die
# Filter-Entscheidung ohne einen Docker-Lauf.
set -euo pipefail
sed -i "s/^    dir: docs\/plan\/planning\/done\$/    dir: docs\/plan\/planning\/done\n    glob: '*.md'/" .d-check.yml
