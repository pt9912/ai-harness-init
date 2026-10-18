#!/usr/bin/env bash
# files: internal/gen/gen.go
# expect: TestGenerateArch_JavaNurFlat
#
# hexslice wird in langArchs("java") eingetragen, ohne dass ein Java-Renderer es rendert ->
# add-lang java --arch hexslice endet nicht mehr mit Exit 2, sondern schriebe ein
# Geruest-only-Skelett (ADR-0094 Festlegung 4).
set -euo pipefail
sed -i 's/"java":   {archFlat},/"java":   {archFlat, archHexslice},/' internal/gen/gen.go
