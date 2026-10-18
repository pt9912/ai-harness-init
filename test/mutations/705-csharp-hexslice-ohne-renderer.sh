#!/usr/bin/env bash
# files: internal/gen/gen.go
# expect: TestGenerateArch_CsharpNurFlat
#
# hexslice wird in langArchs("csharp") eingetragen, ohne dass ein C#-Renderer es rendert ->
# add-lang csharp --arch hexslice endet nicht mehr mit Exit 2, sondern schriebe ein
# Geruest-only-Skelett (ADR-0096 Festlegung 5).
set -euo pipefail
sed -i 's/"csharp": {archFlat},/"csharp": {archFlat, archHexslice},/' internal/gen/gen.go
