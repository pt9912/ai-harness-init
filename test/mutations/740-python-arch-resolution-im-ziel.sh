#!/usr/bin/env bash
# files: internal/gen/python_hexslice.go
# expect: full-smoke: FEHLER — das Python-Arch-Gate ist gruen, loest aber keinen Import auf (resolution der emittierten .a-check.yml?):
# verify: full-smoke
#
# Der Root des resolution-Blocks der Python-.a-check.yml endet nicht im package_base-
# Verzeichnis (src statt src/app). a-check meldet 0 Befunde und den Hinweis "0 von N
# Import-Symbolen"; erst der Lauf-Zahn in der Stufe "add-lang python apps/pythonhexslice --arch
# hexslice" in harness/tools/full-smoke.sh faerbt das (ADR-0095 Festlegung 5: ein falscher Root
# ergibt stilles Gruen).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's|^    roots: \["src/app"\]$|    roots: ["src"]|' internal/gen/python_hexslice.go
