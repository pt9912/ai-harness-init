#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: ein Signal wiederholt einen begonnenen Bericht NICHT
#
# Nimmt die Schranke gegen den doppelten Bericht. Ein Signal, das WAEHREND des Berichts
# eintrifft, startet danach einen zweiten ueber denselben Statusdateien — merge_report und
# report_times zaehlen in pass_count/fail_count weiter, und die Bilanz verdoppelt sich.
# Gemessen ohne die Schranke: `800 ok` ueber 400 Faellen, Vollstaendigkeitszeile zweimal.
# Ein Bericht, der die doppelte Fall-Zahl seiner eigenen Fortschritts-Ausgabe nennt, ist
# genau die Ausgabe, die DoD (2) von slice-117 ausschliesst.
set -euo pipefail
sed -i 's|^  if .*BERICHT_BEGONNEN.*then|  if false; then|' harness/tools/mutate.sh
