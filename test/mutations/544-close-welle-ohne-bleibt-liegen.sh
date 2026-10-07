#!/usr/bin/env bash
# files: internal/emit/templates/commands/close-welle.md
# expect: TestCommands_CloseWelleNenntDieGrenzeAusDerAbstammung
# verify: test-go
#
# Schritt 4 des emittierten close-welle verliert die Vorschau-Zeile der Slices,
# die nach der Grenze liegen bleiben.
set -euo pipefail
sed -i 's/„bleibt liegen (nach der Grenze)"/„spaeter"/' internal/emit/templates/commands/close-welle.md
