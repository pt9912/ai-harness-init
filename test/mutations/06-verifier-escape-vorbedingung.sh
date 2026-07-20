#!/usr/bin/env bash
# files: internal/emit/templates/baseline-verify.sh
# expect: emittiert: GNU-escapter Pfad
#
# Die Format-Vorbedingung greift nie mehr. GNU-escapte Pfade laufen dann in den
# Vollstaendigkeits-Vergleich, der sie nicht dekodiert — falsch-positiv statt
# lautem Abbruch (Befund N3c).
set -euo pipefail
perl -pi -e 's/^if grep -q .*SHA256SUMS; then$/if false; then/' internal/emit/templates/baseline-verify.sh
