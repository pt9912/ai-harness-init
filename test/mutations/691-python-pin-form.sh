#!/usr/bin/env bash
# files: internal/gen/python.go
# expect: TestGenerate_PythonVersionThreaded
#
# DefaultPythonVersion verliert den Varianten-Teil -> kein python-Tag der Form <ver>-slim
# mehr; ein anderes Image waere ein anderer Pin (ADR-0095 Festlegung 2).
set -euo pipefail
sed -i 's/^const DefaultPythonVersion = "3.14.8-slim"$/const DefaultPythonVersion = "3.14.8"/' internal/gen/python.go
