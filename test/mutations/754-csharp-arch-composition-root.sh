#!/usr/bin/env bash
# files: internal/gen/csharp_hexslice.go
# expect: TestArchGateConfig_CsharpResolution
#
# composition_root der C#-.a-check.yml nennt nicht src/App/Program.cs: der Composition Root fiele
# unter die Schichtregeln (ADR-0096 Festlegung 5).
set -euo pipefail
sed -i 's|^composition_root: \["src/App/Program.cs"\]$|composition_root: ["src/App/Main.cs"]|' internal/gen/csharp_hexslice.go
