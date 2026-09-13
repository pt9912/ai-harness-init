#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning: waves.dir zeigt auf docs/plan/planning
#
# Zeigt `waves.dir` auf ein Nachbarverzeichnis statt auf `docs/plan/planning` — die Faehigkeit
# bliebe damit aktiv, aber gegen den falschen Baum gebunden und saehe die flachen Welle-Dateien
# nicht mehr. Dieser Waechter haelt die Pfad-Bindung ohne einen Docker-Lauf.
set -euo pipefail
sed -i 's/^\(    dir: \)docs\/plan\/planning$/\1docs\/plan\/planning\/done/' .d-check.yml
