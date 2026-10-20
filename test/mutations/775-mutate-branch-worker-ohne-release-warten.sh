#!/usr/bin/env bash
# files: .github/workflows/mutate-branch.yml
# expect: workflow: make release-warten ist ein eigener Schritt im Job plan, nach lauf und vor shard
# verify: test-bats
#
# NIMMT DEN WARTE-SCHRITT AUS DEM WORKFLOW: der Job `plan` endet nach `lauf`, die Shards
# starten ihren Gruen-Vorlauf ohne Warten auf das gepinnte Release. Rot faerbt der Fall
# "workflow: make release-warten ist ein eigener Schritt …"; er haelt die Verdrahtung im
# Workflow-Text, nicht die Wirkung gegen ein unveroeffentlichtes Release.
set -euo pipefail
sed -i "/^      - if: steps.lauf.outputs.laufen == 'true'\$/{N;/make release-warten/d}" .github/workflows/mutate-branch.yml
