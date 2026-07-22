#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestEnforce_GuardBlockedSetPerLang
#
# Die @@BLOCKED_SET@@-Substitution im Guard-Emit greift nicht mehr (der ReplaceAll
# sucht einen Platzhalter, den es im Template nicht gibt) -> der emittierte Guard
# behaelt @@BLOCKED_SET@@ und blockt nichts ausser der SHELLS-Rekursion (zahnlos).
# TestEnforce_GuardBlockedSetPerLang wird rot (Platzhalter bleibt / go-Toolchain fehlt).
# Kompiliert weiter (bytes bleibt genutzt).
set -euo pipefail
sed -i 's#\[\]byte("@@BLOCKED_SET@@")#[]byte("@@NOMATCH@@")#' internal/emit/enforce.go
