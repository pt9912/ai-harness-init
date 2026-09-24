#!/usr/bin/env bash
# files: harness/tools/tap-nachzug-nutzlast.sh
# expect: interner fehler: scheitert mktemp in der Nutzlast
# verify: test-bats
#
# LAESST EXIT 1 AUS JEDEM ENDE DURCH: das Ende der Nutzlast setzt Exit 1 nicht mehr auf 2,
# wenn der Vergleich ihn nicht gemeldet hat. Ein Kommando der Nutzlast, das mit 1
# scheitert (mktemp), endet danach als Klasse "Formel-Unterschied".
# Rot faerbt der Fall, dessen mktemp-Stub mit 1 endet und der Exit 2 und die Meldung liest.
set -euo pipefail
sed -i 's|^\t\tif \[ "[$]unterschied" != ja \]; then$|\t\tif false; then|' harness/tools/tap-nachzug-nutzlast.sh
