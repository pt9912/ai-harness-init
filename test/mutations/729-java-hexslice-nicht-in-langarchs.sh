#!/usr/bin/env bash
# files: internal/gen/gen.go
# expect: TestGenerate_JavaHexsliceProfile_FileSet
#
# hexslice fehlt in langArchs("java"): add-lang java --arch hexslice endet mit Exit 2, das
# Layout wird nicht gerendert (ADR-0094 Festlegung 4).
set -euo pipefail
sed -i 's/"java":   {archFlat, archHexslice},/"java":   {archFlat},/' internal/gen/gen.go
