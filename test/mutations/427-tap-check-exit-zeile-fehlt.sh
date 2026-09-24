#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: exit-zeile: bei Exit 1 und Exit 2 ist die letzte stderr-Zeile
# verify: test-bats
#
# NIMMT DEM SKRIPT SEINE EXIT-ZEILE: bei Exit 1 und Exit 2 steht `tap-<modus>: Exit <N>`
# danach nicht mehr als letzte Zeile auf stderr; der Exit selbst bleibt.
# Rot faerbt der Fall, der die letzte stderr-Zeile je Klasse liest.
set -euo pipefail
sed -i '/^\t\tmelde "tap-.*: Exit [$]rc"$/s|.*|\t\t:|' harness/tools/tap-nachzug.sh
