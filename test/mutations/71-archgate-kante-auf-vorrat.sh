#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestArchGateConfig_EdgesMatchSkeleton
#
# Fuegt der emittierten .a-check.yml eine Kante hinzu, die kein Import des Skeletts
# braucht (driven_adapters -> ports_outbound). Sie ist in der Go-Fassung bewusst
# ABWESEND: Outbound-Adapter erfuellen Ports strukturell (Go-Interface-Erfuellung),
# ohne Import — nur die C++-Fassung traegt die Kante, weil dort der Adapter erbt.
# Eine Erlaubnis auf Vorrat lockert das emittierte Gate, ohne dass ein Schicht-Test
# es merkt — die Kanten-Achse der ADR-0009-Fitness-Function faengt es.
set -euo pipefail
sed -i 's|  - {from: driven_adapters,  to: domain}|  - {from: driven_adapters,  to: domain}\n  - {from: driven_adapters,  to: ports_outbound}|' internal/gen/golang.go
