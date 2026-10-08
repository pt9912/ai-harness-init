#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_PlanningBlock
#
# Setzt planning.marker der emittierten Konfiguration auf den Modul-Default. Die emittierte
# Roadmap traegt dann einen Marker, den das Modul nicht sucht, und ein frisches Ziel startet
# rot; der Waechter haelt marker gleich emit.RoadmapRuheMarker.
set -euo pipefail
sed -i 's/^  marker: "Nichts in Arbeit\."$/  marker: "Keine aktive Welle"/' internal/emit/templates/d-check.yml
