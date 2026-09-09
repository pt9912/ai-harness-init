#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning: closure setzt kein eigenes glob (Filter bleibt der Modul-Default slice-glob)
#
# Setzt `glob: '*.md'` unter `closure:` — die in slice-129 verworfene Weitung auf die Welle-Ebene
# (harness/README.md: 20 Befunde gegen den heutigen Bestand, keiner davon fehlende Substanz,
# sondern die auf zwei Dateien verteilte Welle-Closure-Form). `docs-check` selbst faerbt darauf
# jeden Welle-Plan und jede Welle-Ergebnisnotiz unter `done/` rot; dieser Waechter haelt die
# Filter-Entscheidung ohne einen Docker-Lauf.
set -euo pipefail
sed -i "s/^    dir: docs\/plan\/planning\/done\$/    dir: docs\/plan\/planning\/done\n    glob: '*.md'/" .d-check.yml
