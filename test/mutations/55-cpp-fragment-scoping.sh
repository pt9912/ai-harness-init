#!/usr/bin/env bash
# files: internal/gen/cpp.go
# expect: TestCppCodeGateFragment_ScopedSubdir
#
# Die Root-vs-Subdir-Auswahl in cppFragment wird invertiert: ein Subdir-Modul bekaeme die
# UNSCOPED Root-Fassung (test/lint/build, `docker build .`) statt der modul-scoped — im
# Mono-Repo kollidierten zwei cpp-Module auf `test`, Build-Kontext falsch. Rot erwartet.
set -euo pipefail
sed -i 's/if context == "\."/if context != "."/' internal/gen/cpp.go
