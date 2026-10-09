#!/usr/bin/env bash
# files: internal/gen/kotlin.go
# expect: TestArchGateConfig_KotlinEdgesMatchSkeleton
#
# Der Root des resolution-Blocks der Kotlin-.a-check.yml endet nicht im
# package_base-Verzeichnis (src/main/kotlin statt src/main/kotlin/app). a-check stellt den
# Root vor den Import ohne "app." — kein Import loest auf eine Schicht auf, das Gate bleibt
# ueber jedem verbotenen Import gruen (ADR-0088 Festlegung 4, Re-Evaluierungs-Trigger 1).
set -euo pipefail
sed -i 's|^    roots: \["src/main/kotlin/app"\]$|    roots: ["src/main/kotlin"]|' internal/gen/kotlin.go
