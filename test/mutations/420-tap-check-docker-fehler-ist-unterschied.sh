#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: transport: ein Bild, das nicht laeuft (docker Exit 125), endet mit Exit 2 statt 1
# verify: test-bats
#
# MACHT AUS EINEM DOCKER-FEHLER EXIT 1: ein Ende der Nutzlast ausserhalb von 0, 1 und 2
# (docker nicht startbar, Bild nicht ladbar) endet danach als Formel-Unterschied statt als
# nicht ausfuehrbar. Rot faerbt der Fall, dessen docker-Stub mit 125 endet und der Exit 2
# und die Meldung liest.
set -euo pipefail
sed -i 's|^\*) fehler "der Transport im Bild|*) exit 1 ; fehler "der Transport im Bild|' harness/tools/tap-nachzug.sh
