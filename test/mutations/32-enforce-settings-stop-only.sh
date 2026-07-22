#!/usr/bin/env bash
# files: internal/emit/templates/enforce/settings.json
# expect: TestEnforce_SettingsStopOnly
#
# Die emittierte settings.json bekommt einen PreToolUse-Block. Der Command-Guard
# gehoert aber zu slice-032 -- sein Skript wird von slice-031 noch NICHT emittiert,
# ein settings.json-Verweis darauf liefe im Ziel ins Leere. Die Slice-031-Grenze
# (Stop-Hook ja, Guard nein) faellt. TestEnforce_SettingsStopOnly wird rot.
set -euo pipefail
sed -i 's#"Stop"#"PreToolUse": null, "Stop"#' internal/emit/templates/enforce/settings.json
