#!/usr/bin/env bash
# files: internal/gen/csharp_hexslice.go
# expect: TestArchGateConfig_CsharpGlobsMatchRenderedDirs
#
# Die Hexagon-Verzeichnisse werden klein geschrieben gerendert, die Config traegt PascalCase:
# a-check unterscheidet Gross- und Kleinschreibung, IDE0130 nicht — das Arch-Gate saehe die Dateien
# nicht (ADR-0096 Festlegung 5, Luecke zu Skelett-Pflicht (b)). Der Renderer-Test haelt das.
set -euo pipefail
sed -i 's|hex := csHexSrc + "Hexagon/"|hex := csHexSrc + "hexagon/"|' internal/gen/csharp_hexslice.go
