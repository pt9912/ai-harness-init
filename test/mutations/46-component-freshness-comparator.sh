#!/usr/bin/env bash
# files: harness/tools/component-freshness.sh
# expect: component-freshness: aktuell
#
# Invertiert den Gleichheits-Vergleich im generischen Freshness-Sensor
# (aktuell<->veraltet vertauscht): latest==gepinnt faellt dann in den
# VERALTET-Zweig. Ohne den Fixture-Test (test/component-freshness.bats) bliebe die
# Vergleicher-Semantik unbewacht — der Nachtlauf meldete Drift verkehrt herum
# (slice-040, MR-007). Ersetzt das Vergleichs-Token '=' durch '!=' an der EINEN
# Gleichheits-Zeile in compare_tags. Der Match-String traegt bewusst KEIN '$'
# (SC2016-clean): 'latest" = "' ist unter compare_tags eindeutig diese Zeile.
set -euo pipefail
sed -i 's/latest" = "/latest" != "/' harness/tools/component-freshness.sh
