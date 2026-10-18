#!/usr/bin/env bash
# files: internal/gen/csharp_hexslice.go
# expect: TestArchGateConfig_CsharpResolution
#
# Der resolution-Block der C#-.a-check.yml traegt einen anderen mode als fixed-root. a-check loest
# dann using nicht wie in ADR-0096 Festlegung 5 gemessen auf; der Text-Waechter liest den
# Schluessel woertlich.
set -euo pipefail
sed -i 's/^    mode: fixed-root$/    mode: fixed_root/' internal/gen/csharp_hexslice.go
