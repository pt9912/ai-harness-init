#!/usr/bin/env bash
# files: internal/gen/java_hexslice.go
# expect: TestArchGateConfig_JavaResolution
#
# Das package_base der Java-.a-check.yml ist nicht app: a-check streift dann ein anderes
# Praefix vom Import ab als das, das die Pakete des Skeletts tragen (ADR-0094 Festlegung 4).
set -euo pipefail
sed -i 's/^    package_base: "app"$/    package_base: "application"/' internal/gen/java_hexslice.go
