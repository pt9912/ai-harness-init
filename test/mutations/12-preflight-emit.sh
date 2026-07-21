#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestRun_EmitKollisionSchreibtKeinEmit
#
# Der Phase-3-Emit-Pre-Flight bricht nicht mehr ab (slice-025): die Bedingung ist
# konstant falsch, also laeuft eine Emit-Kollision in Phase 4 durch, DocGate
# scheitert am fehlenden docker, und die Pre-Flight-Meldung "existiert bereits"
# faellt weg (Print ist an den Abbruch gebunden) — der Teil-Emit ist zurueck.
set -euo pipefail
sed -i 's/if err := preflightAbsent(targetDir, rels); err != nil {/if err := preflightAbsent(targetDir, rels); err != nil \&\& false {/' cmd/ai-harness-init/main.go
