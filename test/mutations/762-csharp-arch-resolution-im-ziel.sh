#!/usr/bin/env bash
# files: internal/gen/csharp_hexslice.go
# expect: full-smoke: FEHLER — das C#-Arch-Gate ist gruen, loest aber kein using auf (resolution der emittierten .a-check.yml?):
# verify: full-smoke
#
# Der Root des resolution-Blocks der C#-.a-check.yml endet nicht im package_base-Verzeichnis (src
# statt src/App). a-check meldet 0 Befunde und den Hinweis "0 von N Import-Symbolen"; erst der
# Lauf-Zahn in der Stufe "add-lang csharp apps/csharphexslice --arch hexslice" in
# harness/tools/full-smoke.sh faerbt das (ADR-0096 Festlegung 5: ein falscher Root ergibt stilles
# Gruen).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's|^    roots: \["src/App"\]$|    roots: ["src"]|' internal/gen/csharp_hexslice.go
