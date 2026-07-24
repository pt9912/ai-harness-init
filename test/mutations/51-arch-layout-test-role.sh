#!/usr/bin/env bash
# files: internal/gen/arch.go
# expect: TestGenerate_CppProfile
#
# Entfernt die Test-Rolle aus dem flat-Arch-Layout (`roleEntrypoint, roleTest` ->
# `roleEntrypoint`): das komponierte cpp-Skelett verliert dann tests/CMakeLists.txt
# + tests/test_main.cpp, sein Datei-Satz weicht ab. Ohne den Byte-Anker
# TestGenerate_CppProfile (exakter Datei-Satz) bliebe der Seam unbewacht — eine
# Rolle koennte still aus dem Layout fallen (slice-044, ADR-0008). go bleibt gruen
# (goRole(test)=nil), also faerbt genau die cpp-Byte-Zusage rot. Match `roleEntrypoint,
# roleTest` ist SC2016-clean und in arch.go eindeutig die archLayout-flat-Zeile.
set -euo pipefail
sed -i 's/roleEntrypoint, roleTest/roleEntrypoint/' internal/gen/arch.go
