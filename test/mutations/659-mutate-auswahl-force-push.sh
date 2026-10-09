#!/usr/bin/env bash
# files: harness/tools/mutate-auswahl.sh
# expect: grenze: das Werkzeug gibt nie einen Force-Push aus
#
# Das Urteil gibt wieder einen Force-Push aus — ein Agent ohne dieses Recht bliebe stehen,
# und ein Push mit -f ueberschriebe einen fremden Ergebnis-Commit (LH-QA-03).
set -euo pipefail
sed -i 's/git push origin HEAD:refs/git push -f origin HEAD:refs/' harness/tools/mutate-auswahl.sh
