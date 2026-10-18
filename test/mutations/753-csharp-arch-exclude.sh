#!/usr/bin/env bash
# files: internal/gen/csharp_hexslice.go
# expect: TestArchGateConfig_CsharpResolution
#
# Der exclude der C#-.a-check.yml nennt nicht tests/**: der Test-Baum fiele in den
# Produktions-Abhaengigkeitsgraphen. Die Wirkung im Ziel ist an keiner Fixture gemessen.
set -euo pipefail
sed -i 's|^  - "tests/\*\*"$|  - "test/**"|' internal/gen/csharp_hexslice.go
