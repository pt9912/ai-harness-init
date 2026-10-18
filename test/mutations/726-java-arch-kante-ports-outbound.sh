#!/usr/bin/env bash
# files: internal/gen/java_hexslice.go
# expect: TestArchGateConfig_JavaEdgesMatchSkeleton
#
# Die Kante driven_adapters -> ports_outbound fehlt in der Java-.a-check.yml, obwohl der
# getriebene Adapter seinen Port implementiert und importiert. Der Skelett-Import hat dann
# keine erlaubte Kante. Den Lauf mit dem echten a-check faerbt Fall 727.
set -euo pipefail
sed -i 's/^  - {from: driven_adapters,  to: ports_outbound}.*$/  # Kante entfernt/' internal/gen/java_hexslice.go
