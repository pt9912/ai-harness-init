#!/usr/bin/env bash
# files: internal/gen/csharp_hexslice.go
# expect: TestArchGateConfig_CsharpResolution
#
# package_base der C#-.a-check.yml traegt nicht App: a-check streift dann einen falschen Praefix
# vom Namensraum ab (ADR-0096 Festlegung 5).
set -euo pipefail
sed -i 's/^    package_base: "App"$/    package_base: "Hexagon"/' internal/gen/csharp_hexslice.go
