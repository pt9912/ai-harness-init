#!/usr/bin/env bash
# files: internal/gen/java_hexslice.go
# expect: TestArchGateConfig_JavaResolution
#
# Der resolution-Block der Java-.a-check.yml traegt einen anderen mode als fixed-root.
# a-check loest dann Importe nicht wie in ADR-0094 Festlegung 4 gemessen auf; der Text-Waechter
# liest den Schluessel woertlich.
set -euo pipefail
sed -i 's/^    mode: fixed-root$/    mode: fixed_root/' internal/gen/java_hexslice.go
