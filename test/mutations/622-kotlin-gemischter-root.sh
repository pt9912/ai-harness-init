#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: full-smoke: FEHLER — make test am gemischten Root mit Kotlin ohne Beleg fuer: [--target test -t kotlin:] — ein Kontext fiel heraus.
# verify: full-smoke
#
# add-lang kotlin . waehlt am gemischten Root die unscoped Fassung statt der gemischten:
# das Kotlin-Fragment traegt dann eigene Rezepte fuer test/lint/build mit dem Tag app:, das
# Kotlin-Modul baut nie unter kotlin:. Die Stufe "gemischter Root go+cpp+kotlin" in
# harness/tools/full-smoke.sh muss den fehlenden Kotlin-Kontext melden (LH-FA-04).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's/^\t\tif other == lang {$/\t\tif other == lang || lang == "kotlin" {/' cmd/ai-harness-init/main.go
