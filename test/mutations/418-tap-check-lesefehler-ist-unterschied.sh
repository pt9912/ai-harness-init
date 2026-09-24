#!/usr/bin/env bash
# files: harness/tools/tap-nachzug-nutzlast.sh
# expect: nicht lesbar: der Tap ist nicht erreichbar oder lehnt ab
# verify: test-bats
#
# MACHT AUS EINEM LESEFEHLER DEN UNTERSCHIED: ein Tap, der nicht erreichbar ist (Statuscode
# 000, 500), endet danach mit dem Status 10 der Nutzlast und damit als Formel-Unterschied statt
# als nicht ausfuehrbar.
# Rot faerbt der Fall, der Exit 2 und die Meldung "Tap nicht lesbar" fuer 000, 403, 429
# und 500 liest.
set -euo pipefail
sed -i 's|^\t\*) fehler "Tap nicht lesbar (HTTP|\t*) unterschied=ja ; exit 10 ; fehler "Tap nicht lesbar (HTTP|' harness/tools/tap-nachzug-nutzlast.sh
