#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: transport: ein docker-Aufruf ohne Ergebnis der Nutzlast
# verify: test-bats
#
# MACHT DEN STATUS 1 DES DOCKER-AUFRUFS ZUM UNTERSCHIED: der Status, den der docker-Client bei
# nicht erreichbarem Daemon liefert, gilt danach wie der Status 10 der Nutzlast und endet als
# Exit 1 statt als nicht ausfuehrbar. Rot faerbt der Fall, dessen docker-Stub mit 1 endet und
# Exit 2 liest; die uebrigen Status bleiben gruen.
set -euo pipefail
sed -i 's#^10)$#1 | 10)#' harness/tools/tap-nachzug.sh
