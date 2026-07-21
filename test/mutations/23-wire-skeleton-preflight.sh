#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestRun_SkeletonKollisionSchreibtKeinEmit
#
# Die Skelett-Root-Ziele fallen aus dem Phase-3-Pre-Flight: eine Makefile-Kollision
# am Root wird nicht mehr vor dem Emit gefangen -> Teil-Bootstrap (slice-025-Klasse
# fuer die verdrahteten Skelett-Dateien).
set -euo pipefail
sed -i 's|wire.Targets(filepath.Join(targetDir, ".harness", "skeleton"))|[]string(nil), error(nil)|' cmd/ai-harness-init/main.go
