#!/usr/bin/env bash
# files: harness/tools/archive-welle.sh
# expect: Klasse fremd: das Welle-Feld nennt eine ANDERE Welle — sie bleibt liegen
#
# Macht aus der Rest-Klasse eine Mitgliedschaft: was keine Wellenlosigkeit
# erklaert, gilt danach als Mitglied DIESER Welle. Die Slices einer noch
# offenen Welle wanderten dann in ein fremdes Archiv, und ihre Plan-Dateien
# waeren mitten in der Arbeit ein Stub.
set -euo pipefail
sed -i 's/fremd\\n/mitglied\\n/' harness/tools/archive-welle.sh
