#!/usr/bin/env bash
# files: docs/user/benutzerhandbuch.md
# expect: Handbuch-Baum (dokument-only): vom Lauf angelegt, im Handbuch nicht genannt: [harness/erfassung-feldliste.md]
# verify: full-smoke
#
# Streicht im Baum der Phase 1 die Zeile harness/erfassung-feldliste.md, die der Lauf
# weiter anlegt. Die Stufe "Handbuch-Baum" in harness/tools/full-smoke.sh muss den Pfad
# als angelegt, aber nicht genannt melden — die Gegenrichtung zu 614–616
# (harness/tools/handbuch-baum.sh, nur_ziel).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i '/^│   ├── erfassung-feldliste\.md /d' docs/user/benutzerhandbuch.md
