#!/usr/bin/env bash
# files: internal/gen/arch.go
# expect: TestArchGateConfig_CoversEveryLayeredCombo
#
# archGateConfigs() fuehrt keine Config fuer python: das hexSlice-Layout rendert Schichten und
# hat kein Arch-Gate — es faellt lautlos aus (LH-QA-01).
set -euo pipefail
sed -i '/^		"python": {archHexslice: pythonHexArchConfig},$/d' internal/gen/arch.go
