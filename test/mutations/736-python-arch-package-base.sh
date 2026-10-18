#!/usr/bin/env bash
# files: internal/gen/python_hexslice.go
# expect: TestArchGateConfig_PythonResolution
#
# package_base der Python-.a-check.yml heisst nicht app: der Abstreif-Schritt von a-check traefe
# den Import-Praefix der Skelett-Dateien nicht (ADR-0095 Festlegung 5).
set -euo pipefail
sed -i 's/^    package_base: "app"$/    package_base: "pkg"/' internal/gen/python_hexslice.go
