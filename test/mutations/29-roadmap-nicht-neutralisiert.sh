#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_RoadmapGateSafe
#
# Der NeutralizeRoadmap-Aufruf faellt weg: die geloeschte case-Zeile hinterlaesst einen
# leeren case-Fall, der in das gemeinsame `return body, nil` am Funktionsende laeuft
# (roadmapTemplate bleibt in der Bedingung genutzt -> kompiliert). Die emittierte
# Roadmap traegt danach wieder den broken ../done/welle-NN-results.md-Link.
set -euo pipefail
sed -i '/return NeutralizeRoadmap(body), nil/d' internal/emit/templates.go