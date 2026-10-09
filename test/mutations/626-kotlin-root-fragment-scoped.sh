#!/usr/bin/env bash
# files: internal/gen/kotlin.go
# expect: TestRun_BootstrapKotlinRoot
# verify: test-go
#
# Das Kotlin-Fragment erkennt den Root-Kontext "." nicht mehr und liefert am Root die
# modul-scoped Fassung: der One-Shot --lang kotlin legt dann ein harness/mk/kotlin.mk ohne die
# unscoped Ziele test/lint/build ab, make gates am Root faehrt kein Kotlin-Gate (LH-FA-04).
set -euo pipefail
sed -i 's/^\tif context == "\." {$/\tif context == ".\/" {/' internal/gen/kotlin.go
