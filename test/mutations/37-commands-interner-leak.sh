#!/usr/bin/env bash
# files: internal/emit/templates/commands/implement-slice.md
# expect: TestCommands_NoInternalLeak
#
# Der ai-harness-init-interne Sensorname `make mutate` (den die Emission NICHT
# mitliefert) kehrt in den emittierten Command zurück -> eine Referenz, die im
# Ziel-Repo tot/falsch ist (LH-FA-08 „nicht 1:1 hart" verletzt).
# TestCommands_NoInternalLeak wird rot.
set -euo pipefail
sed -i 's/in den Mutations-Sensor deines Repos/in den make mutate Sensor/' internal/emit/templates/commands/implement-slice.md
