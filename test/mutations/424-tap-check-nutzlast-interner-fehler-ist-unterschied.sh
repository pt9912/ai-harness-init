#!/usr/bin/env bash
# files: harness/tools/tap-nachzug-nutzlast.sh
# expect: interner fehler: ein Kommando der Nutzlast mit dem Status des Unterschieds (10)
# verify: test-bats
#
# LAESST DEN STATUS DES UNTERSCHIEDS AUS JEDEM ENDE DURCH: das Ende der Nutzlast setzt Status 10
# nicht mehr auf 2, wenn der Vergleich ihn nicht gemeldet hat. Ein Kommando der Nutzlast, das
# mit 10 scheitert (mktemp), endet danach als Klasse "Formel-Unterschied".
# Rot faerbt der Fall, dessen mktemp-Stub mit 10 endet und den Exit 2 und die Meldung liest.
set -euo pipefail
sed -i 's|^\t\tif \[ "[$]unterschied" != ja \]; then$|\t\tif false; then|' harness/tools/tap-nachzug-nutzlast.sh
