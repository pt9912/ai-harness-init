#!/usr/bin/env bash
# files: internal/gen/python_hexslice.go
# expect: TestArchGateConfig_PythonResolution
#
# Der Root des resolution-Blocks endet nicht im package_base-Verzeichnis (src statt src/app).
# a-check streift package_base vom Import ab und stellt dann den Root voran: ein Import loest
# nicht mehr auf. Der Text-Waechter liest den Root woertlich; den Lauf im Ziel faerbt Fall 740.
set -euo pipefail
sed -i 's|^    roots: \["src/app"\]$|    roots: ["src"]|' internal/gen/python_hexslice.go
