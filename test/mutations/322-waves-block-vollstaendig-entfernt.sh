#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning: waves ist ueber dir aktiviert
#
# Entfernt den gesamten `waves:`-Unterblock (Schluessel, `dir:` und `mode:`) unter `planning:`,
# laesst roadmap/heading/marker/closure unveraendert. Die Zusicherung "planning: waves ist ueber
# dir aktiviert" (test/waves-modul-wiring.bats) prueft genau diesen Fall — einen leeren oder
# fehlenden `waves:`-Block; 319 entfernt nur `dir:` (der Block bleibt nicht-leer, weil `mode:`
# stehen bleibt), 320/321 aendern nur Feldwerte und lassen den Block ebenfalls nicht-leer. Dieser
# Fall entfernt den Block als Ganzes und faerbt genau diese Zusicherung rot.
set -euo pipefail
sed -i \
  -e '/^  waves:$/d' \
  -e '/^    dir: docs\/plan\/planning$/d' \
  -e '/^    mode: many$/d' \
  .d-check.yml
