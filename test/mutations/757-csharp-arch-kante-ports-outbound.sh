#!/usr/bin/env bash
# files: internal/gen/csharp_hexslice.go
# expect: TestArchGateConfig_CsharpEdgesMatchSkeleton
#
# Die Kante driven_adapters -> ports_outbound fehlt in der C#-.a-check.yml, obwohl der getriebene
# Adapter das Port-Interface implementiert und importiert. Den Lauf mit dem echten a-check faerbt
# Fall 763.
set -euo pipefail
sed -i 's/^  - {from: driven_adapters,  to: ports_outbound}.*$/  # Kante entfernt/' internal/gen/csharp_hexslice.go
