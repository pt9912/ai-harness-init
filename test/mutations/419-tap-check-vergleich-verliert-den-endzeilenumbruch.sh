#!/usr/bin/env bash
# files: harness/tools/tap-nachzug-nutzlast.sh
# expect: vergleich byte-genau: verschieden nur im Endzeilenumbruch endet mit Exit 1
# verify: test-bats
#
# VERGLEICHT ueber Kommandosubstitution statt ueber Dateien: `$(cat …)` verliert den
# Endzeilenumbruch, und zwei Formeln, die sich nur darin unterscheiden, gelten als gleich.
# Rot faerbt der Fall, dessen Tap-Stand das Asset plus Endzeilenumbruch ist.
set -euo pipefail
sed -i 's|if cmp -s "[$]work/asset" "[$]work/tap"; then|if [ "\x24(cat "\x24work/asset")" = "\x24(cat "\x24work/tap")" ]; then|' harness/tools/tap-nachzug-nutzlast.sh
