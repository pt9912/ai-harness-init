#!/usr/bin/env bash
# files: harness/tools/tap-nachzug-nutzlast.sh
# expect: interner fehler: ein Kommando der Nutzlast mit Status 1 oder ab 3
# verify: test-bats
#
# BILDET EINEN STATUS AB 3 NICHT AUF 2 AB: das Ende der Nutzlast setzt einen Status ausserhalb
# von 0, 2 und 10 nicht mehr auf 2. Ein Kommando der Nutzlast, das mit 1, 3 oder 127 scheitert
# (mktemp), endet danach mit diesem Status.
# Rot faerbt der Fall, dessen mktemp-Stub so endet und den Exit 2 der Nutzlast liest.
set -euo pipefail
sed -i 's|^\t\trc=2$|\t\t:|' harness/tools/tap-nachzug-nutzlast.sh
