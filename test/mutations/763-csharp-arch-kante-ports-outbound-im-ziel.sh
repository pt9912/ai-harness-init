#!/usr/bin/env bash
# files: internal/gen/csharp_hexslice.go
# expect: full-smoke: FEHLER — make gates nach add-lang csharp --arch hexslice faellt an wrong-direction driven_adapters -> ports_outbound: die Kante fehlt
# verify: full-smoke
#
# Die Kante driven_adapters -> ports_outbound fehlt in der C#-.a-check.yml. Der Adapter
# InMemoryRepository implementiert das Port-Interface und importiert es; der echte a-check im
# gebootstrappten Ziel meldet das using als wrong-direction. Die Stufe liest die Ausgabe des
# Gate-Laufs auf genau diese Ursache und nennt sie in der Meldung (ADR-0096 Festlegung 5, Kante am
# C#-Fall im Ziel gemessen).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's/^  - {from: driven_adapters,  to: ports_outbound}.*$/  # Kante entfernt/' internal/gen/csharp_hexslice.go
