#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_PlanningReadmeCarveoutsDoneRefGateSafe
#
# Der NeutralizePlanningReadmeCarveoutsDoneRef-Aufruf faellt weg -> die
# emittierte docs/plan/planning/README.md traegt die
# docs/plan/carveouts/done/-Zeile wieder ohne den d-check:ignore-Marker
# (ADR-0037 Festlegung 4, Fundstelle 2). Der if-Rumpf bleibt leer, aber
# planningReadmeTemplate wird weiter in der Bedingung genutzt -> kompiliert.
set -euo pipefail
sed -i '/body = NeutralizePlanningReadmeCarveoutsDoneRef(body)/d' internal/emit/templates.go
