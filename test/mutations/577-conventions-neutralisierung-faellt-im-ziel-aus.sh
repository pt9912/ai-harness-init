#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: make gates im emittierten Repo ist NICHT Exit 0
# verify: full-smoke
#
# Der NeutralizeConventionsTemplateRef-Aufruf faellt weg: die emittierte
# harness/conventions.md traegt wieder den Inline-Code-Pfad
# harness/conventions/MR-NNN-titel.template.md, den es im Ziel nicht gibt. codepaths ist im
# emittierten Pruefbereich aktiv; make gates des frischen Ziels faellt am docs-check mit
# codepath-missing (der gruene Start in harness/tools/full-smoke.sh). Der Fall haelt das
# Rot; die Ursache steht in der mitgedruckten Ausgabe.
set -euo pipefail
sed -i '/body = NeutralizeConventionsTemplateRef(body)/d' internal/emit/templates.go
