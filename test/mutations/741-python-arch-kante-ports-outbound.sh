#!/usr/bin/env bash
# files: internal/gen/python_hexslice.go
# expect: TestArchGateConfig_PythonEdgesMatchSkeleton
#
# Die Kante driven_adapters -> ports_outbound fehlt in der Python-.a-check.yml, obwohl der
# getriebene Adapter den Port erbt und importiert. Der Skelett-Import hat dann keine erlaubte
# Kante. Den Lauf mit dem echten a-check faerbt Fall 742.
set -euo pipefail
sed -i 's/^  - {from: driven_adapters,  to: ports_outbound}.*$/  # Kante entfernt/' internal/gen/python_hexslice.go
