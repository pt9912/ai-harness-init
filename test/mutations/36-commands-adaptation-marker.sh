#!/usr/bin/env bash
# files: internal/emit/templates/commands/implement-slice.md
# expect: TestCommands_AdaptationMarker
#
# Der ANPASSEN-Marker fällt aus der „Repo-lokale Adaptionen"-Sektion des emittierten
# Commands -> die repo-spezifische Stelle ist wieder 1:1 hart, nicht adaptierbar
# (LH-FA-08-Verstoß). TestCommands_AdaptationMarker wird rot.
set -euo pipefail
sed -i 's/ANPASSEN/ANGEPASST/g' internal/emit/templates/commands/implement-slice.md
