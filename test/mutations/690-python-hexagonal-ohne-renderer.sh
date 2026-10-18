#!/usr/bin/env bash
# files: internal/gen/gen.go
# expect: TestGenerateArch_PythonOhneHexagonal
#
# hexagonal wird in langArchs("python") eingetragen, ohne dass ein Python-Renderer es rendert ->
# add-lang python --arch hexagonal endet nicht mehr mit Exit 2, sondern schriebe ein
# Geruest-only-Skelett (ADR-0095 Festlegung 5).
set -euo pipefail
sed -i 's/"python": {archFlat, archHexslice},/"python": {archFlat, archHexslice, archHexagonal},/' internal/gen/gen.go
