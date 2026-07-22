#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_RoadmapGateSafe
#
# Der NeutralizeRoadmap-Aufruf faellt weg -> die emittierte Roadmap traegt wieder
# den broken ../done/welle-NN-results.md-Link (der dritte Befund aus slice-024s
# Voll-Smoke). Der if-Rumpf bleibt leer, aber roadmapTemplate wird weiter in der
# Bedingung genutzt -> kompiliert.
set -euo pipefail
sed -i '/body = NeutralizeRoadmap(body)/d' internal/emit/templates.go
