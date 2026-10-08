#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_RoadmapTraegtRuheMarker
#
# Nimmt die Marker-Injektion aus dem Roadmap-Zweig von neutralisiereJeDatei; die Funktion
# selbst bleibt unveraendert. Die emittierte Roadmap traegt dann keinen Ruhe-Marker, und
# der Verdrahtungs-Test faerbt rot.
set -euo pipefail
sed -i 's/^\t\treturn InjectRoadmapRuheMarker(NeutralizeRoadmap(body)), nil$/\t\treturn NeutralizeRoadmap(body), nil/' internal/emit/templates.go
