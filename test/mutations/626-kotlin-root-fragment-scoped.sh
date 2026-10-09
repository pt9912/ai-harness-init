#!/usr/bin/env bash
# files: internal/gen/kotlin.go
# expect: TestKotlinCodeGateFragment_RootUndSubdir
# verify: test-go
#
# Das Kotlin-Fragment erkennt den Root-Kontext "." nicht mehr und liefert am Root die
# modul-scoped Fassung: der One-Shot --lang kotlin legt dann ein harness/mk/kotlin.mk ohne die
# unscoped Ziele test/lint/build ab, make gates am Root faehrt kein Kotlin-Gate (LH-FA-04).
# Die Mutation faerbt zwei Tests rot, TestKotlinCodeGateFragment_RootUndSubdir (das Fragment
# direkt) und TestRun_BootstrapKotlinRoot (dasselbe Fragment ueber den Bootstrap); keiner der
# beiden bindet die Zeile allein. Der Fall nennt den Test, der die Stelle direkt liest.
set -euo pipefail
sed -i 's/^\tif context == "\." {$/\tif context == ".\/" {/' internal/gen/kotlin.go
