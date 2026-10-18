#!/usr/bin/env bash
# files: internal/gen/gen.go
# expect: TestGenerate_PythonHexsliceProfile_FileSet
#
# hexslice fehlt in langArchs("python"): add-lang python --arch hexslice endet mit Exit 2, das
# Layout wird nicht gerendert (ADR-0095 Festlegung 5).
set -euo pipefail
sed -i 's/"python": {archFlat, archHexslice},/"python": {archFlat},/' internal/gen/gen.go
