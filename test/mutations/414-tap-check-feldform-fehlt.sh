#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: feldform: fuehrende Null und mehr als 9 Stellen im Kern enden mit Exit 2
# verify: test-bats
#
# NIMMT DER FELDFORM-PRUEFUNG IHRE BEDINGUNG: `v01.0.0` und `v1.0.1234567890` gehen
# danach in den docker-Aufruf. Die Nutzlast rechnet nicht mit den Feldern; die Grenze
# haelt allein diese Pruefung auf dem Host, vor docker.
# Rot faerbt der Fall, der Exit, Meldung und den ausbleibenden docker-Aufruf liest.
set -euo pipefail
sed -i 's@^\tif ! \[\[ "[$]k" =~ [$]feld_form \]\]; then$@\tif false; then@' harness/tools/tap-nachzug.sh
