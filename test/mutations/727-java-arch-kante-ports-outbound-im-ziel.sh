#!/usr/bin/env bash
# files: internal/gen/java_hexslice.go
# expect: full-smoke: FEHLER — make gates nach add-lang java --arch hexslice ist NICHT Exit 0 (Java-hexSlice-Gate kaputt).
# verify: full-smoke
#
# Die Kante driven_adapters -> ports_outbound fehlt in der Java-.a-check.yml. Der Adapter
# InMemoryRepository implementiert den Port und importiert ihn; der echte a-check im
# gebootstrappten Ziel meldet den Import als wrong-direction, make gates faellt (ADR-0094
# Festlegung 4, Vererbungs-Kante).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's/^  - {from: driven_adapters,  to: ports_outbound}.*$/  # Kante entfernt/' internal/gen/java_hexslice.go
