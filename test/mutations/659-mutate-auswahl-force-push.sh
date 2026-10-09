#!/usr/bin/env bash
# files: harness/tools/mutate-auswahl.sh
# expect: grenze: der Ergebnis-Schritt pusht ohne Force auf genau seinen Ref
#
# Der Ergebnis-Schritt pusht mit -f: ein zweiter Lauf auf demselben Ref ueberschriebe einen
# fremden Ergebnis-Commit, und der Schreibschritt braeuchte ein Recht, das er nicht fuehrt (LH-QA-03).
set -euo pipefail
sed -i 's/ push origin "HEAD:refs/ push -f origin "HEAD:refs/' harness/tools/mutate-auswahl.sh
