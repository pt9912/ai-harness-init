#!/usr/bin/env bash
# files: internal/gen/csharp.go
# expect: TestCsharpTFM_FolgtMajorMinorDesTags
#
# Die TFM-Ableitung schreibt einen festen Wert statt Major.Minor des Tags -> ein anderer Tag
# (9.0.100, 10.1.100) erhaelt eine TFM, die sein SDK nicht baut (NETSDK1045, ADR-0096 Festlegung 2).
set -euo pipefail
sed -i 's/return "net" + m\[1\] + "." + m\[2\], nil/return "net10.0", nil/' internal/gen/csharp.go
