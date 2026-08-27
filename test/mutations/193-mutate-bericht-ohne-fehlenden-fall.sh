#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: merge_report FAELLT, wenn ein Fall ohne Ergebnis geblieben ist
#
# Entschaerft die Vollstaendigkeits-Pruefung der Zusammenfuehrung: ein Fall ohne
# Statuszeile wird danach nicht mehr gemeldet. Genau so sieht ein gestorbener Worker
# aus — der Bericht bliebe kuerzer und gruen, statt rot zu werden.
# Das ist der Zahn zu DoD (3) aus slice-105: der zusammengefuehrte Bericht ist
# vollstaendig oder rot, nie still gruen.
set -euo pipefail
sed -i "s/\"\$missing_n\" -gt 0/\"\$missing_n\" -gt 999999/" harness/tools/mutate.sh
