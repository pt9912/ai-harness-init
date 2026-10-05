#!/usr/bin/env bash
# files: internal/emit/templates/commands/close-welle.md
# expect: TestCommands_CloseWelleNenntAltbestandUndUntergrenze
# verify: test-go
#
# Schritt 4 des emittierten close-welle verliert die Sperre untergrenze.
set -euo pipefail
sed -i 's/\[untergrenze\]/[sperre]/' internal/emit/templates/commands/close-welle.md
