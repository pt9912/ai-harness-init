#!/usr/bin/env bash
# files: internal/gen/csharp_hexslice.go
# expect: TestArchGateConfig_CsharpEdgesMatchSkeleton
#
# Die C#-.a-check.yml deklariert eine Kante (driving_adapters -> domain), die kein Skelett-using
# braucht: die Kanten-Menge ist enger als deklariert (ADR-0096 Festlegung 5, Kanten in beide
# Richtungen).
set -euo pipefail
sed -i '/^  - {from: driven_adapters,  to: domain}/a\  - {from: driving_adapters, to: domain}' internal/gen/csharp_hexslice.go
