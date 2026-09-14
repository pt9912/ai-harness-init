#!/usr/bin/env bash
# files: internal/emit/templates/enforce/history-range-guard.sh
# expect: TestEnforce_HistoryRangeGuardZaehltDieRangeMitGit
#
# NIMMT DEM EMITTIERTEN WAECHTER DIE RANGE-ZAEHLUNG.
#
# Ohne `git rev-list --count` entscheidet das Skript nicht mehr ueber die Commit-Zahl der
# angeforderten Range — genau der Wert, an dem der Leerfall haengt ("0 Commits"). Der
# Waechter bliebe ein Skript mit denselben Meldungen, aber ohne die Messung, die sie
# ausloest: das Ziel haette weiter einen Vorlauf, der ueber leerem Pruefbereich gruen
# durchlaesst.
set -euo pipefail
sed -i 's/git rev-list --count/git rev-list --max-count/' internal/emit/templates/enforce/history-range-guard.sh
