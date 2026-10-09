#!/usr/bin/env bash
# files: harness/tools/mutate-auswahl.sh
# expect: lauf: ein Ref ohne Praefix mutate/ bricht ab
#
# kennung_aus_ref nimmt jeden Ref an: der Ergebnis-Schritt pushte dann auch auf einen Branch
# ausserhalb von mutate/ (MR-014, fail-closed).
set -euo pipefail
sed -i 's/^    abbruch "Ref .\{4\} hat nicht die Form .*kein Push"$/    echo x/' harness/tools/mutate-auswahl.sh
