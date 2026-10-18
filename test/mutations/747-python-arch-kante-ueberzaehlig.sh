#!/usr/bin/env bash
# files: internal/gen/python_hexslice.go
# expect: TestArchGateConfig_PythonEdgesMatchSkeleton
#
# Die Python-.a-check.yml deklariert eine Kante (driving_adapters -> domain), die kein
# Skelett-Import braucht: die Kanten-Menge ist enger als deklariert (ADR-0095 Festlegung 5,
# Kanten in beide Richtungen).
set -euo pipefail
sed -i '/^  - {from: driven_adapters,  to: domain}/a\  - {from: driving_adapters, to: domain}' internal/gen/python_hexslice.go
