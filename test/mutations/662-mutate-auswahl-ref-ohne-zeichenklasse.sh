#!/usr/bin/env bash
# files: harness/tools/mutate-auswahl.sh
# expect: lauf: ein Ref mit Shell-Zeichen bricht mit Exit 2 ab und fuehrt nichts aus
#
# kennung_aus_ref nimmt jedes Zeichen in der Kennung an: ein Ref mit Shell-Zeichen erreicht
# GITHUB_OUTPUT und die Folgeschritte (MR-014, fail-closed).
set -euo pipefail
sed -i 's/=~ ^mutate\/(\$KENNUNG_KLASSE)-/=~ ^mutate\/(.+)-/' harness/tools/mutate-auswahl.sh
