#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: interner fehler: scheitert ein Kommando des Skripts selbst mit einem Status ab 3
# verify: test-bats
#
# BILDET EINEN STATUS AB 3 NICHT AUF 2 AB: das Ende des Host-Skripts setzt einen Status ausserhalb
# von 0, 1 und 2 nicht mehr auf 2. Ein Kommando des Skripts, das mit 127 scheitert (der Pfad der
# Nutzlast), endet danach mit diesem Status.
# Rot faerbt der Fall, dessen pwd mit 127 endet und Exit 2 und die Meldung liest.
set -euo pipefail
sed -i 's|^\t\trc=2$|\t\t:|' harness/tools/tap-nachzug.sh
