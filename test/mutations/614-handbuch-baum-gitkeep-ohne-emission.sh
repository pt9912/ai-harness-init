#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: Handbuch-Baum (dokument-only): im Handbuch genannt, vom Lauf nicht angelegt: [docs/plan/carveouts/] [docs/plan/carveouts/.gitkeep]
# verify: full-smoke
#
# Nimmt docs/plan/carveouts aus structureGitkeeps(): der Bootstrap legt den Ordner nicht
# mehr an, das Handbuch nennt ihn weiter. Die Stufe "Handbuch-Baum" in
# harness/tools/full-smoke.sh liest den Bestand am frischen Ziel und muss die beiden
# Pfade als genannt, aber nicht angelegt melden (docs/user/benutzerhandbuch.md §6).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i '/^\t\t"docs\/plan\/carveouts",$/d' internal/emit/templates.go
