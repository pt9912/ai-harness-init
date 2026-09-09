#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning: closure setzt kein eigenes glob (Filter bleibt der Modul-Default slice-glob)
#
# Setzt `glob: '*.md'` unter `closure:` — die verworfene Weitung auf die Welle-Ebene
# (harness/README.md: zwei Fundklassen gegen den heutigen Bestand, keine davon fehlende
# Substanz, sondern die auf zwei Dateien verteilte Welle-Closure-Form). `docs-check` selbst
# faerbt darauf jeden Welle-Plan und jede Welle-Ergebnisnotiz unter `done/` rot; dieser
# Waechter haelt die Filter-Entscheidung ohne einen Docker-Lauf.
set -euo pipefail
sed -i "s/^    dir: docs\/plan\/planning\/done\$/    dir: docs\/plan\/planning\/done\n    glob: '*.md'/" .d-check.yml
