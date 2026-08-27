#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: die Spur-Zuordnung ist dieselbe, ob aus einer Shell oder aus einem Sub-make gerufen
#
# Gibt dem Trockenlauf die make-Umgebung seines Aufrufers zurueck. `make mutate` ruft den
# Treiber aus einer Rezeptur; ein `make` darin ist ein Sub-make und rahmt seinen Plan mit
# `make[1]: Verzeichnis …`-Zeilen ein. Die sind kein docker-Aufruf, also faellt JEDER
# Modus in die serielle Spur — der Lauf ist danach wieder sequentiell, ohne dass irgendwo
# ein Fehler gemeldet wuerde. Beide Abwehrlinien fallen zusammen, weil jede fuer sich
# genuegt: nur wenn beide weg sind, kippt die Zuordnung.
set -euo pipefail
sed -i "s@env -u MAKEFLAGS -u MAKELEVEL -u MFLAGS \\\\@\\\\@" harness/tools/mutate.sh
sed -i "s@make --no-print-directory -n @make -n @" harness/tools/mutate.sh
