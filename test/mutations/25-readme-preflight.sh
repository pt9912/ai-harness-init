#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestRun_ReadmeKollisionSchreibtKeinEmit
#
# Das Root-README-Ziel faellt aus dem Phase-3-Pre-Flight: eine vorhandene README.md
# am Ziel-Root wird nicht mehr vor dem Emit gefangen -> Teil-Bootstrap (slice-025-
# Klasse fuer die emittierte README, LH-FA-05).
set -euo pipefail
sed -i 's/, emit.RootReadmePath}/}/' cmd/ai-harness-init/main.go
