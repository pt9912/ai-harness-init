#!/usr/bin/env bash
# files: internal/emit/templates/enforce/pretooluse-command-guard.sh
# expect: TestEnforce_GuardBakedFloorAndUnion
#
# Der gebackene universelle Boden wird aus dem emittierten Guard entfernt
# (BLOCKED="apt ..." -> BLOCKED=""). Dann blockt der Guard NICHTS mehr aus dem Boden
# (fail-OPEN, ADR-0007 NEU-H1) — pip/apt liefen ungehindert. Der Guard-Waechter (er prueft
# BLOCKED="apt) muss rot werden. Real auch im full-smoke-Fail-safe-Check sichtbar.
set -euo pipefail
sed -i 's/BLOCKED="apt.*/BLOCKED=""/' internal/emit/templates/enforce/pretooluse-command-guard.sh
