#!/usr/bin/env bash
# files: internal/emit/templates/commands/close-welle.md
# expect: TestCommands_CloseWelleNenntAltbestandUndUntergrenze
# verify: test-go
#
# Schritt 4 des emittierten close-welle verliert den Schluessel altbestand.
set -euo pipefail
sed -i 's/WELLE=altbestand/WELLE=<alt>/' internal/emit/templates/commands/close-welle.md
