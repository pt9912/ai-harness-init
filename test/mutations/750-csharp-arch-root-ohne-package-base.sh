#!/usr/bin/env bash
# files: internal/gen/csharp_hexslice.go
# expect: TestArchGateConfig_CsharpResolution
#
# Der Root des resolution-Blocks endet nicht im package_base-Verzeichnis (src statt src/App).
# a-check streift package_base vom Namensraum ab und stellt dann den Root voran: ein using loest
# nicht mehr auf. Der Text-Waechter liest den Root woertlich; den Lauf im Ziel faerbt Fall 762.
set -euo pipefail
sed -i 's|^    roots: \["src/App"\]$|    roots: ["src"]|' internal/gen/csharp_hexslice.go
