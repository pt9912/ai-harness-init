#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestArchGateConfig_EdgesMatchSkeleton
#
# Fuegt der emittierten .a-check.yml eine Kante hinzu, die kein Import des Skeletts
# braucht (adapters -> ports). Sie ist in der kanonischen Referenz bewusst ABWESEND:
# Outbound-Adapter erfuellen Ports strukturell, ohne Import. Eine Erlaubnis auf Vorrat
# lockert das emittierte Gate, ohne dass ein Schicht-Test es merkt — die Kanten-Achse der
# ADR-0009-Fitness-Function faengt es.
set -euo pipefail
sed -i 's|  - {from: ports,    to: domain}|  - {from: ports,    to: domain}\n  - {from: adapters, to: ports}|' internal/gen/golang.go
