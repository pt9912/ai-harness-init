#!/usr/bin/env bash
# files: internal/gen/python_hexslice.go
# expect: TestArchGateConfig_PythonResolution
#
# Der resolution-Block der Python-.a-check.yml traegt einen anderen mode als fixed-root. a-check
# loest dann Importe nicht wie in ADR-0095 Festlegung 5 gemessen auf; der Text-Waechter liest
# den Schluessel woertlich.
set -euo pipefail
sed -i 's/^    mode: fixed-root$/    mode: fixed_root/' internal/gen/python_hexslice.go
