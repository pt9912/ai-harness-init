#!/usr/bin/env bash
# files: internal/emit/templates/commands/close-welle.md
# expect: TestCommands_CloseWelleNenntAltbestandUndUntergrenze
# verify: test-go
#
# Schritt 4 des emittierten close-welle verliert die Ablehnung [kein-schreib-pfad].
set -euo pipefail
sed -i 's/\[kein-schreib-pfad\]/[abgewiesen]/' internal/emit/templates/commands/close-welle.md
