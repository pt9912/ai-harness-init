#!/usr/bin/env bash
# files: internal/gen/python_hexslice.go
# expect: TestArchGateConfig_PythonResolution
#
# Die gerenderten Python-Pfade liegen unter src/pkg statt src/app, ohne dass die Config
# mitzieht: der Root der Config traefe keine Produktionsdatei (Pfad-gegen-Config-Kopplung,
# ADR-0095 Festlegung 5).
set -euo pipefail
sed -i 's|^const pyHexSrc = "src/app/"$|const pyHexSrc = "src/pkg/"|' internal/gen/python_hexslice.go
