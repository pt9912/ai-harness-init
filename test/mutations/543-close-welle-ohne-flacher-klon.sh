#!/usr/bin/env bash
# files: internal/emit/templates/commands/close-welle.md
# expect: TestCommands_CloseWelleNenntDieGrenzeAusDerAbstammung
# verify: test-go
#
# Schritt 4 des emittierten close-welle verliert die Shallow-Sperre [flacher-klon].
set -euo pipefail
sed -i 's/\[flacher-klon\]/[flach]/' internal/emit/templates/commands/close-welle.md
