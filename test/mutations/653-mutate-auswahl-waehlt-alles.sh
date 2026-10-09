#!/usr/bin/env bash
# files: harness/tools/mutate-auswahl.sh
# expect: auswahl: ein unberuehrter Fall ist nicht gewaehlt
#
# Die Auswahl waehlt jeden Fall, ob seine files-Angabe eine geaenderte Datei trifft oder
# nicht — der Lauf wuerde breiter und verloere die Schwelle (MR-014).
set -euo pipefail
sed -i 's/if \[\[ ".f" =~ .(muster_zu_regex ".spec") \]\]; then/if true; then/' harness/tools/mutate-auswahl.sh
