#!/usr/bin/env bash
# files: internal/gen/csharp_hexslice.go
# expect: TestArchGateConfig_CsharpResolution
#
# Die gerenderten C#-Pfade liegen unter src/Pkg statt src/App, ohne dass die Config mitzieht: der
# Root der Config traefe keine Produktionsdatei (Pfad-gegen-Config-Kopplung, ADR-0096 Festlegung 5).
set -euo pipefail
sed -i 's|^const csHexSrc = "src/App/"$|const csHexSrc = "src/Pkg/"|' internal/gen/csharp_hexslice.go
