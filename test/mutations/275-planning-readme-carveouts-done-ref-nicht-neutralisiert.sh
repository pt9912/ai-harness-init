#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_PlanningReadmeCarveoutsDoneRefGateSafe
#
# Der NeutralizePlanningReadmeCarveoutsDoneRef-Aufruf faellt weg: die geloeschte
# case-Zeile hinterlaesst einen leeren case-Fall, der in das gemeinsame
# `return body, nil` am Funktionsende laeuft (planningReadmeTemplate bleibt in der
# Bedingung genutzt -> kompiliert). Die emittierte docs/plan/planning/README.md
# traegt die docs/plan/carveouts/done/-Zeile wieder ohne den d-check:ignore-Marker
# (ADR-0037 Festlegung 4).
set -euo pipefail
sed -i '/return NeutralizePlanningReadmeCarveoutsDoneRef(body), nil/d' internal/emit/templates.go