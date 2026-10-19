#!/usr/bin/env bash
# files: docs/user/benutzerhandbuch.md
# expect: Handbuch-Baum (kotlin): vom Lauf angelegt, im Handbuch nicht genannt: [src/test/kotlin/app/MainTest.kt]
# verify: full-smoke
#
# Streicht im Baum der Phase 2 fuer --lang kotlin die Zeile von src/test/kotlin/app/MainTest.kt, die der Lauf weiter anlegt.
# Die Stufe "Handbuch-Baum" in harness/tools/full-smoke.sh muss den Pfad als angelegt, aber
# nicht genannt melden — und damit belegen, dass die Schleife das Ziel --lang kotlin faehrt
# (harness/tools/handbuch-baum.sh, nur_ziel).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i '/^│               └── MainTest\.kt$/d' docs/user/benutzerhandbuch.md
