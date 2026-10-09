#!/usr/bin/env bash
# files: internal/gen/kotlin.go
# expect: full-smoke: FEHLER — make gates am Kotlin-Root-Modul ohne Beleg fuer:
# verify: full-smoke
#
# Das Kotlin-Fragment erkennt den Root-Kontext "." nicht mehr und liefert am Root die
# modul-scoped Fassung. Kein frueherer Abschnitt des Voll-E2E bootstrappt Kotlin am Root;
# erst die Stufe "Root-Bootstrap (--lang kotlin --arch hexslice)" in
# harness/tools/full-smoke.sh liest die Gradle-Gates im make gates des Ziels und vermisst
# die unscoped Ziele mit dem Tag app: (LH-FA-04, ADR-0088).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's/^\tif context == "\." {$/\tif context == ".\/" {/' internal/gen/kotlin.go
