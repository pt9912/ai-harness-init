#!/usr/bin/env bash
# files: internal/gen/csharp_hexslice.go
# expect: TestArchGateConfig_CsharpResolution
#
# Der languages-Glob der C#-.a-check.yml trifft keine .cs-Datei: das Gate scannte nichts
# (LH-QA-01).
set -euo pipefail
sed -i 's|^  csharp: \["\*\*/\*\.cs"\]$|  csharp: ["**/*.csx"]|' internal/gen/csharp_hexslice.go
