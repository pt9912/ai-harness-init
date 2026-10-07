#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_RoadmapGateSafe
#
# Der NeutralizeRoadmap-Aufruf faellt weg: die geloeschte case-Zeile hinterlaesst einen
# leeren case-Fall, der in das gemeinsame `return body, nil` am Funktionsende laeuft
# (roadmapTemplate bleibt in der Bedingung genutzt -> kompiliert). Die emittierte
# Roadmap eines aelteren Kurs-Stands traegt danach wieder den toten
# ../done/welle-NN-results.md-Link (LH-FA-02).
set -euo pipefail
sed -i '/return NeutralizeRoadmap(body), nil/d' internal/emit/templates.go
