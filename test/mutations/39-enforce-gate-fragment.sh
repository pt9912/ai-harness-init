#!/usr/bin/env bash
# files: internal/emit/templates/enforce/enforce.mk
# expect: TestEnforce_EmitsGateFragment
#
# Das record-gates-Rezept im Enforce-Fragment ruft ein falsches Skript
# (record-gates.sh -> record-gates-xxx.sh) — im Ziel liefe der Gate-Nachweis dann
# ins Leere (der Stop-Hook haette keinen Stempel). Der Fragment-Waechter, der den
# emittierten Skript-Pfad prueft, muss rot werden. Ersetzt zusammen mit Fall 38 die
# Deckung des entfernten Falls 33 (record-gates-Verdrahtung, jetzt Aggregator + Fragment).
set -euo pipefail
sed -i 's|tools/harness/record-gates.sh|tools/harness/record-gates-xxx.sh|' internal/emit/templates/enforce/enforce.mk
