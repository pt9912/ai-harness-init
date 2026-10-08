#!/usr/bin/env bash
# files: docs/user/benutzerhandbuch.md
# expect: Handbuch-Baum (dokument-only): im Handbuch genannt, vom Lauf nicht angelegt: [CLAUDE.md]
# verify: full-smoke
#
# Erfindet im Baum der Phase 1 eine Datei, die kein Emissions-Pfad anlegt (CLAUDE.md).
# Die Stufe "Handbuch-Baum" in harness/tools/full-smoke.sh muss sie als genannt, aber
# nicht angelegt melden.
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's/^├── repo\.mk   .*$/&\n├── CLAUDE.md                          erfunden/' docs/user/benutzerhandbuch.md
