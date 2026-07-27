#!/usr/bin/env bash
# files: internal/gen/cpp.go
# expect: TestGenerate_CppHexsliceProfile_FileSet
#
# Entfernt die Domain-Rolle-Datei aus cppRole (die Map-Zeile mit `cppHexDomain}`): das
# komponierte cpp-hexSlice-Skelett verliert dann src/hexagon/domain/example/greeting.hpp,
# sein Datei-Satz weicht ab. Ohne den exakten Datei-Satz-Anker
# TestGenerate_CppHexsliceProfile_FileSet (slice-053) koennte eine Schicht-Datei still aus
# dem Layout fallen — dieselbe Klasse, die Fall 61 fuer den Go-Renderer verankert.
# Match `cppHexDomain}` trifft NUR die Map-Zeile in cppRole (die const-Definition heisst
# `cppHexDomain = `), ist eindeutig und SC2016-clean.
set -euo pipefail
sed -i '/cppHexDomain}/d' internal/gen/cpp.go
