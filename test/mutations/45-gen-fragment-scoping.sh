#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestCodeGateFragment_ScopedSubdir
#
# Die Root-vs-Subdir-Auswahl in goFragment wird invertiert: dann bekommt ein Subdir-Modul
# die UNSCOPED Root-Fassung (Targets test/lint/build, `docker build .`) statt der modul-
# scoped (`docker build <pfad>`) — im Mono-Repo kollidierten zwei Module auf `test`, und der
# Build-Kontext waere falsch. Der Scoping-/Kontext-Waechter muss rot werden.
set -euo pipefail
sed -i 's/if context == "\."/if context != "."/' internal/gen/golang.go
