#!/usr/bin/env bash
# files: internal/gen/kotlin.go
# expect: full-smoke: FEHLER — make gates nach add-lang kotlin ist NICHT Exit 0 (Kotlin-Gate kaputt).
# verify: full-smoke
#
# Das Kotlin-Skelett bekommt eine leere Funktion (detekt-Regel EmptyFunctionBlock). Die
# Go-Tests lesen den Inhalt von Main.kt nicht bis dahin; erst der reale detekt-Lauf der
# lint-Stage im gebootstrappten Ziel faerbt make gates rot — die Stufe "add-lang kotlin
# apps/kt" in harness/tools/full-smoke.sh belegt, dass der Lint im Ziel wirklich laeuft
# (LH-QA-01, ADR-0088 Festlegung 3).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's/^    println(greeting("Welt"))$/&\n}\n\nfun leer() {/' internal/gen/kotlin.go
