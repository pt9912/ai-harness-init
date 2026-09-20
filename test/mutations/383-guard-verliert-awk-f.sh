#!/usr/bin/env bash
# files: internal/emit/templates/enforce/pretooluse-command-guard.sh
# expect: TestEnforce_GuardBashAwkOnly
#
# NIMMT DEM GUARD DIE `-f`-FORM SEINES AWK-AUFRUFS: awk bekommt das Skript dann als
# Kommandozeilen-Argument statt als Datei — der Extraktor liefe nicht mehr als Datei
# hinter `-f`. LH-QA-03 verlangt bash+awk statt node/jq; diese Form ist der Anker.
set -euo pipefail
sed -i 's@awk -f "@awk "@' internal/emit/templates/enforce/pretooluse-command-guard.sh
