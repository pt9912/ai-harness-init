#!/usr/bin/env bash
# files: docs/user/benutzerhandbuch.md
# expect: Handbuch-Baum (python): vom Lauf angelegt, im Handbuch nicht genannt: [tests/test_main.py]
# verify: full-smoke
#
# Streicht im Baum der Phase 2 fuer --lang python die Zeile von tests/test_main.py, die der Lauf weiter anlegt.
# Die Stufe "Handbuch-Baum" in harness/tools/full-smoke.sh muss den Pfad als angelegt, aber
# nicht genannt melden — und damit belegen, dass die Schleife das Ziel --lang python faehrt
# (harness/tools/handbuch-baum.sh, nur_ziel).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i '/^│   └── test_main\.py$/d' docs/user/benutzerhandbuch.md
