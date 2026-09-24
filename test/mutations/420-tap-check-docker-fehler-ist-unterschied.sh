#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: transport: ein docker-Aufruf ohne Ergebnis der Nutzlast
# verify: test-bats
#
# MACHT AUS EINEM DOCKER-FEHLER EXIT 1: ein Ende des docker-Aufrufs ausserhalb von 0, 2 und
# 10 (docker nicht startbar, Bild nicht ladbar) endet danach als Formel-Unterschied statt als
# nicht ausfuehrbar. Rot faerbt der Fall, dessen docker-Stub mit 1, 3, 125 und 127 endet und
# Exit 2, die Meldung des Transports und die Exit-Zeile liest.
set -euo pipefail
sed -i 's|^\*) fehler "der Transport im Bild|*) unterschied=ja ; exit 1 ; fehler "der Transport im Bild|' harness/tools/tap-nachzug.sh
