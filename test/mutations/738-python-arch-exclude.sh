#!/usr/bin/env bash
# files: internal/gen/python_hexslice.go
# expect: TestArchGateConfig_PythonResolution
#
# Der exclude-Glob der Python-.a-check.yml trifft tests/ nicht mehr: Tests gingen in den
# Produktions-Abhaengigkeitsgraphen ein (ADR-0095 Festlegung 5).
set -euo pipefail
sed -i 's|^  - "tests/\*\*"$|  - "test/**"|' internal/gen/python_hexslice.go
