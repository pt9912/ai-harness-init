#!/usr/bin/env bash
# files: internal/emit/templates/enforce/settings.json
# expect: TestEnforce_SettingsWiresBothHooks
#
# Der Guard-Verweis faellt aus dem PreToolUse-Block der emittierten settings.json ->
# der Command-Guard ist nicht mehr verdrahtet (nur der Stop-Hook liefe), im Ziel
# griffe der Guard nie. Die slice-031-Grenze war „Stop-only"; slice-032 verdrahtet
# BEIDE Hooks. TestEnforce_SettingsWiresBothHooks verliert pretooluse-command-guard.sh
# -> rot.
set -euo pipefail
sed -i 's#pretooluse-command-guard.sh#guard-DISABLED.sh#' internal/emit/templates/enforce/settings.json
