#!/usr/bin/env bash
# files: internal/gen/python_hexslice.go
# expect: full-smoke: FEHLER — make gates nach add-lang python --arch hexslice ist NICHT Exit 0 (Python-hexSlice-Gate kaputt).
# verify: full-smoke
#
# Die Kante driven_adapters -> ports_outbound fehlt in der Python-.a-check.yml. Der Adapter
# InMemoryRepository erbt den Port und importiert ihn; der echte a-check im gebootstrappten Ziel
# meldet den Import als wrong-direction, make gates faellt (ADR-0095 Festlegung 5,
# Vererbungs-Kante).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's/^  - {from: driven_adapters,  to: ports_outbound}.*$/  # Kante entfernt/' internal/gen/python_hexslice.go
