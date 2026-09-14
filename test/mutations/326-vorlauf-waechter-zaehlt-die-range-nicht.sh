#!/usr/bin/env bash
# files: internal/emit/templates/enforce/history-range-guard.sh
# expect: TestEnforce_HistoryRangeGuardZaehltDieRangeMitGit
#
# NIMMT DEM EMITTIERTEN WAECHTER DIE RANGE-ZAEHLUNG.
#
# Ohne die Zaehlung entscheidet das Skript nicht mehr ueber die Commit-Zahl der
# angeforderten Range — genau der Wert, an dem der Leerfall haengt ("0 Commits"). Der
# Waechter bliebe ein Skript mit denselben Meldungen, aber ohne die Messung, die sie
# ausloest: das Ziel haette weiter einen Vorlauf, der ueber leerem Pruefbereich gruen
# durchlaesst.
#
# DER OPERAND TRIFFT NUR DIE AUSFUEHRENDE ZEILE, nicht den Wortlaut im Kopfkommentar: der
# Kommentar nennt `git rev-list --count` ohne Argument, der Aufruf traegt `"$range"`. Ein
# Operand auf das blosse Kommando machte aus dem Fall eine Probe darauf, dass IRGENDWO im
# Skript noch das Stichwort steht — die Prosa erfuellte sie mit. Der Dollar des Arguments
# steht in einer Klammer-Klasse (`[$]`), sonst laese shellcheck ihn als Variable.
set -euo pipefail
sed -i 's/git rev-list --count "[$]range"/git rev-list --max-count "[$]range"/' internal/emit/templates/enforce/history-range-guard.sh
