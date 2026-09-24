#!/usr/bin/env bash
# files: harness/tools/tap-nachzug-nutzlast.sh
# expect: vergleich byte-genau: verschieden nur im Endzeilenumbruch endet mit Exit 1
# verify: test-bats
#
# VERGLEICHT ueber Kommandosubstitution statt ueber Dateien: `$(cat …)` verliert den
# Endzeilenumbruch, und zwei Formeln, die sich nur darin unterscheiden, gelten als gleich.
# Rot faerbt der Fall, dessen Tap-Stand das Asset plus Endzeilenumbruch ist.
set -euo pipefail
sed -i 's|^\tcmp -s "[$]work/asset" "[$]work/tap" \|\| cmp_rc=[$]?$|\t[ "\x24(cat "\x24work/asset")" = "\x24(cat "\x24work/tap")" ] \|\| cmp_rc=1|' harness/tools/tap-nachzug-nutzlast.sh
