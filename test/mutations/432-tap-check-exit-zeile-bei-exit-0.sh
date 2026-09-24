#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: exit-zeile: bei Exit 1 und Exit 2 ist die letzte stderr-Zeile
# verify: test-bats
#
# SCHREIBT DIE EXIT-ZEILE AUCH BEI EXIT 0: ein gleicher Vergleich und ein Vorab-Tag enden
# danach mit `tap-<modus>: Exit 0` auf stderr, obwohl bei Exit 0 keine Zeile zugesagt ist.
# Rot faerbt der Fall, der bei Exit 0 keine Exit-Zeile liest.
set -euo pipefail
sed -i 's|^\tif \[ "[$]rc" -ne 0 \]; then$|\tif true; then|' harness/tools/tap-nachzug.sh
