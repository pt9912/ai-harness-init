#!/usr/bin/env bash
# files: docs/user/benutzerhandbuch.md
# expect: Handbuch-Baum (csharp): vom Lauf angelegt, im Handbuch nicht genannt: [.editorconfig]
# verify: full-smoke
#
# Streicht im Baum der Phase 2 fuer --lang csharp die Zeile von .editorconfig, die der Lauf weiter anlegt.
# Die Stufe "Handbuch-Baum" in harness/tools/full-smoke.sh muss den Pfad als angelegt, aber
# nicht genannt melden — und damit belegen, dass die Schleife das Ziel --lang csharp faehrt
# (harness/tools/handbuch-baum.sh, nur_ziel).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i '/^├── \.editorconfig /d' docs/user/benutzerhandbuch.md
