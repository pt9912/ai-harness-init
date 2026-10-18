#!/usr/bin/env bash
# files: internal/gen/gen.go
# expect: TestGenerateArch_JavaOhneHexagonal
#
# hexagonal wird in langArchs("java") eingetragen, ohne dass ein Java-Renderer es rendert ->
# add-lang java --arch hexagonal endet nicht mehr mit Exit 2, sondern schriebe ein
# Geruest-only-Skelett (ADR-0094 Festlegung 4: java traegt flat und hexslice).
set -euo pipefail
sed -i 's/"java":   {archFlat, archHexslice},/"java":   {archFlat, archHexslice, archHexagonal},/' internal/gen/gen.go
