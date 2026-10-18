#!/usr/bin/env bash
# files: internal/gen/java_hexslice.go
# expect: TestArchGateConfig_JavaEdgesMatchSkeleton
#
# Der Root des resolution-Blocks der Java-.a-check.yml endet nicht im package_base-Verzeichnis
# (src/main/java statt src/main/java/app). a-check stellt den Root vor den Import ohne "app." —
# kein Import loest auf eine Schicht auf, das Gate bleibt ueber jedem verbotenen Import gruen
# (ADR-0094 Festlegung 4). Den Lauf im gebootstrappten Ziel faerbt Fall 725.
set -euo pipefail
sed -i 's|^    roots: \["src/main/java/app"\]$|    roots: ["src/main/java"]|' internal/gen/java_hexslice.go
