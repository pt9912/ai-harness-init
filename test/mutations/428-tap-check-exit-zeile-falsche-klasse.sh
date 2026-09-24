#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: exit-zeile: bei Exit 1 und Exit 2 ist die letzte stderr-Zeile
# verify: test-bats
#
# LAESST DIE EXIT-ZEILE IMMER DIE KLASSE 1 NENNEN: ein Lauf mit Exit 2 schreibt danach
# `tap-<modus>: Exit 1`, der Prozess-Exit bleibt 2. Die Klasse, die die Zeile tragen soll,
# ist damit falsch. Rot faerbt der Fall, der die Klasse je Lauf liest; der Lauf mit Exit 1
# bleibt gruen.
set -euo pipefail
sed -i "/^\t\tprintf .tap-%s: Exit %s/s|\"[\$]rc\" >&2\$|1 >\&2|" harness/tools/tap-nachzug.sh
