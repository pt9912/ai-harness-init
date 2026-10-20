#!/usr/bin/env bash
# files: .github/workflows/mutate-branch.yml
# expect: workflow: der Warte-Schritt laeuft nur, wenn lauf einen Lauf ergeben hat
# verify: test-bats
#
# ENTFERNT DIE BEDINGUNG AM WARTE-SCHRITT: er laeuft auch fuer einen Tip, dessen einzige
# Aenderung die Ergebnisdatei ist, und wartet dort bis zur Grenze, obwohl kein Shard folgt.
# Rot faerbt der Fall "workflow: der Warte-Schritt laeuft nur, …". Er haelt die Bedingung im
# Workflow-Text, nicht dass GitHub sie so auswertet.
set -euo pipefail
sed -i "s/^      - if: steps.lauf.outputs.laufen == 'true'\$/      - name: warten/" .github/workflows/mutate-branch.yml
