#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: ein zweites Signal sagt, dass es OHNE Bericht abbricht
#
# Nimmt dem zweiten Signal seine Meldung: der Lauf bricht danach still ab, nachdem die Zeile
# davor zugesagt hat, dass berichtet wird. Eine Ausgabe, die ihre eigene Zusage schweigend
# bricht, ist derselbe Defekt wie ein Bericht, der seiner Fortschritts-Ausgabe widerspricht
# — nur eine Zeile frueher.
set -euo pipefail
sed -i 's|^    echo .*zweites.*|    :|' harness/tools/mutate.sh
