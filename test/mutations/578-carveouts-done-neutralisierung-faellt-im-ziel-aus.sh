#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: make gates im emittierten Repo ist NICHT Exit 0
# verify: full-smoke
#
# Der NeutralizePlanningReadmeCarveoutsDoneRef-Aufruf faellt weg: die emittierte
# docs/plan/planning/README.md nennt docs/plan/carveouts/done/ wieder ohne den
# d-check:ignore-Marker, und das Verzeichnis legt der Bootstrap nicht an. codepaths ist im
# emittierten Pruefbereich aktiv; make gates des frischen Ziels faellt am docs-check mit
# codepath-missing (der gruene Start in harness/tools/full-smoke.sh). Der Fall haelt das
# Rot; die Ursache steht in der mitgedruckten Ausgabe.
set -euo pipefail
sed -i '/return NeutralizePlanningReadmeCarveoutsDoneRef(body), nil/d' internal/emit/templates.go
