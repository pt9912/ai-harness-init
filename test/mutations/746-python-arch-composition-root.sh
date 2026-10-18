#!/usr/bin/env bash
# files: internal/gen/python_hexslice.go
# expect: TestArchGateConfig_PythonResolution
#
# composition_root der Python-.a-check.yml nennt nicht src/app/main.py: der Composition Root
# fiele unter die Schichtregeln (ADR-0095 Festlegung 5).
set -euo pipefail
sed -i 's|^composition_root: \["src/app/main.py"\]$|composition_root: ["src/app/app.py"]|' internal/gen/python_hexslice.go
