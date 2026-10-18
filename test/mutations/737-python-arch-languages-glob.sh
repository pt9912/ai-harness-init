#!/usr/bin/env bash
# files: internal/gen/python_hexslice.go
# expect: TestArchGateConfig_PythonResolution
#
# Der languages-Glob der Python-.a-check.yml trifft keine .py-Datei: a-check scannte nichts,
# das Gate bliebe ueber jedem Import gruen (ADR-0095 Festlegung 5).
set -euo pipefail
sed -i 's|^  python: \["\*\*/\*\.py"\]$|  python: ["**/*.pyi"]|' internal/gen/python_hexslice.go
