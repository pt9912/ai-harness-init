#!/usr/bin/env bash
# files: harness/tools/tap-nachzug-nutzlast.sh
# expect: interner fehler: liefert cmp in der Nutzlast Status 2
# verify: test-bats
#
# LAESST CMP MIT STATUS 2 ALS VERSCHIEDEN GELTEN: ein Vergleich, der nicht lesen konnte,
# endet danach mit "verschieden" statt mit einem nicht ausfuehrbaren Lauf.
# Rot faerbt der Fall, dessen cmp-Stub mit 2 endet und Exit 2 und die Meldung liest.
set -euo pipefail
sed -i 's|^\t\*) fehler "der Vergleich lief nicht|\t*) return 1 ; : "der Vergleich lief nicht|' harness/tools/tap-nachzug-nutzlast.sh
