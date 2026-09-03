#!/usr/bin/env bash
# files: harness/tools/archive-welle.sh
# expect: Klasse mitglied: das Welle-Feld nennt die Welle
#
# Nimmt der Einsammel-Regel ihre erste Klasse: ein Slice, dessen `Welle:`-Feld
# genau diese Welle nennt, gilt danach als fremd und bleibt liegen. Das Archiv
# der Welle enthielte dann ihre eigenen Slices nicht — und weil ein Zip opak
# ist, liest das kein Gate nach.
set -euo pipefail
sed -i 's/mitglied\\n/fremd\\n/' harness/tools/archive-welle.sh
