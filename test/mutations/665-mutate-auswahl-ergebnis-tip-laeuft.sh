#!/usr/bin/env bash
# files: harness/tools/mutate-auswahl.sh
# expect: lauf: ein Tip, der allein die Ergebnisdatei aendert, startet keinen Lauf
#
# Der Ergebnis-Commit startet wieder einen Lauf: jeder Lauf schriebe einen neuen Tip und
# loeste den naechsten aus (MR-014).
set -euo pipefail
sed -i 's/if \[ ".geaendert" = ".ERGEBNIS" \]; then/if false; then/' harness/tools/mutate-auswahl.sh
