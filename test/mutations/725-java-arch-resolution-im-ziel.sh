#!/usr/bin/env bash
# files: internal/gen/java_hexslice.go
# expect: full-smoke: FEHLER — das Java-Arch-Gate ist gruen, loest aber keinen Import auf (resolution der emittierten .a-check.yml?):
# verify: full-smoke
#
# Der Root des resolution-Blocks der Java-.a-check.yml endet nicht im package_base-
# Verzeichnis (src/main/java statt src/main/java/app). a-check meldet 0 Befunde und den
# Hinweis "0 von N Import-Symbolen"; erst der Lauf-Zahn in der Stufe
# "add-lang java apps/javahexslice --arch hexslice" in harness/tools/full-smoke.sh faerbt
# das (ADR-0094 Festlegung 4: ein falscher Root ergibt stilles Gruen).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's|^    roots: \["src/main/java/app"\]$|    roots: ["src/main/java"]|' internal/gen/java_hexslice.go
