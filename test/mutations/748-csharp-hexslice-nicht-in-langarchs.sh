#!/usr/bin/env bash
# files: internal/gen/gen.go
# expect: TestGenerate_CsharpHexsliceProfile_FileSet
#
# hexslice fehlt in langArchs("csharp"): add-lang csharp --arch hexslice endet mit Exit 2, das
# Layout wird nicht gerendert (ADR-0096 Festlegung 5).
set -euo pipefail
sed -i 's/"csharp": {archFlat, archHexslice},/"csharp": {archFlat},/' internal/gen/gen.go
