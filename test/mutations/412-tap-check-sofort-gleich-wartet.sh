#!/usr/bin/env bash
# files: harness/tools/tap-nachzug-nutzlast.sh
# expect: cache-fenster: sofort gleich liest einmal und wartet nicht
# verify: test-bats
#
# MACHT DAS ERSTE LESEN NIE GLEICH: vergleiche() wartet und liest danach immer ein
# zweites Mal, auch wenn der erste Stand schon gleich war. Das Ergebnis bleibt Exit 0,
# nur die Wartezeit und der zweite Lese-Aufruf sind zu viel.
# Rot faerbt der Fall "sofort gleich": er liest die Zahl der Lese-Aufrufe und das
# Wartezeit-Protokoll.
set -euo pipefail
sed -i '0,\|^\tif cmp -s "[$]work/asset" "[$]work/tap"; then$|s||\tif false; then|' harness/tools/tap-nachzug-nutzlast.sh
