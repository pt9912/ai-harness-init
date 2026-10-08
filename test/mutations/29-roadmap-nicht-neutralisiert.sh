#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_RoadmapGateSafe
#
# Der NeutralizeRoadmap-Aufruf faellt weg: die Ruhe-Marker-Injektion bekommt den
# unneutralisierten Body (die Injektion bleibt, Fall 571 haelt sie). Die emittierte
# Roadmap eines aelteren Kurs-Stands traegt danach wieder den toten
# ../done/welle-NN-results.md-Link (LH-FA-02).
set -euo pipefail
sed -i 's/^\t\treturn InjectRoadmapRuheMarker(NeutralizeRoadmap(body)), nil$/\t\treturn InjectRoadmapRuheMarker(body), nil/' internal/emit/templates.go
