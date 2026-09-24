#!/usr/bin/env bash
# files: harness/tools/tap-nachzug-nutzlast.sh
# expect: cache-fenster: erst alt, dann neu endet mit Exit 0 nach zwei Lese-Aufrufen und einer Wartezeit
# verify: test-bats
#
# NIMMT DER UNGLEICHHEIT IHR ZWEITES LESEN: nach der Wartezeit vergleicht vergleiche() den
# Stand des ersten Lesens noch einmal, ohne den Tap-Kopf erneut zu lesen. Ein Stand, den das
# Cache-Fenster der Schnittstelle noch alt liefert, wird danach als Formel-Unterschied
# gemeldet. Rot faerbt der Fall "erst alt, dann neu": Exit 0 und zwei Lese-Aufrufe.
set -euo pipefail
sed -i '/^\tsleep "[$]TAP_WAIT"$/{n;s/^\tlese_tap$/\t:/}' harness/tools/tap-nachzug-nutzlast.sh
