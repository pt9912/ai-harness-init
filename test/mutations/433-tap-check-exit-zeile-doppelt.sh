#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: exit-zeile: bei Exit 1 und Exit 2 ist die letzte stderr-Zeile
# verify: test-bats
#
# SCHREIBT DIE EXIT-ZEILE ZWEIMAL: beende nimmt den EXIT-Trap nicht mehr zurueck, und das
# Verlassen aus beende ruft es ein zweites Mal auf; bei Exit 1 und Exit 2 steht die Zeile
# danach doppelt.
# Rot faerbt der Fall, der die Exit-Zeilen je Lauf zaehlt.
set -euo pipefail
sed -i '/^\ttrap - EXIT$/d' harness/tools/tap-nachzug.sh
