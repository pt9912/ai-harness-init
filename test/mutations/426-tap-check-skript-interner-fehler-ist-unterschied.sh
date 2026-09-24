#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: interner fehler: scheitert ein Kommando des Skripts selbst
# verify: test-bats
#
# LAESST EXIT 1 AUS JEDEM ENDE DURCH: das Ende des Host-Skripts setzt Exit 1 nicht mehr auf 2,
# wenn die Nutzlast ihn nicht gemeldet hat. Ein Kommando des Skripts, das mit 1 scheitert
# (der Pfad der Nutzlast), endet danach als Klasse "Formel-Unterschied".
# Rot faerbt der Fall, dessen pwd scheitert und der Exit 2, die Meldung und die Exit-Zeile liest.
set -euo pipefail
sed -i 's|^\t\tif \[ "[$]unterschied" != ja \]; then$|\t\tif false; then|' harness/tools/tap-nachzug.sh
