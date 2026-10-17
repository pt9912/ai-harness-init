#!/usr/bin/env bash
# files: internal/gen/gen.go
# expect: TestGenerateArch_PythonNurFlat
#
# hexslice wird in langArchs("python") eingetragen, ohne dass ein Python-Renderer es rendert ->
# add-lang python --arch hexslice endet nicht mehr mit Exit 2, sondern schriebe ein
# Geruest-only-Skelett (ADR-0095 Festlegung 5).
set -euo pipefail
sed -i 's/"python": {archFlat},/"python": {archFlat, archHexslice},/' internal/gen/gen.go
