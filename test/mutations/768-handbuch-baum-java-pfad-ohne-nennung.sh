#!/usr/bin/env bash
# files: docs/user/benutzerhandbuch.md
# expect: Handbuch-Baum (java): vom Lauf angelegt, im Handbuch nicht genannt: [config/checkstyle/checkstyle.xml]
# verify: full-smoke
#
# Streicht im Baum der Phase 2 fuer --lang java die Zeile von config/checkstyle/checkstyle.xml, die der Lauf weiter anlegt.
# Die Stufe "Handbuch-Baum" in harness/tools/full-smoke.sh muss den Pfad als angelegt, aber
# nicht genannt melden — und damit belegen, dass die Schleife das Ziel --lang java faehrt
# (harness/tools/handbuch-baum.sh, nur_ziel).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i '/^│       └── checkstyle\.xml /d' docs/user/benutzerhandbuch.md
