#!/usr/bin/env bash
# files: internal/archive/stub.go
# expect: TestSliceKennungAusTitelSuffixBleibtDieNummer
# verify: test-go
#
# Vertauscht NUR die Reihenfolge der beiden sliceRE-Alternativen (in POSIX-
# Lesart dasselbe Muster, in Go-`regexp` — leftmost-first, keine
# leftmost-longest-Wahl — nicht): die Kebab-Alternative gewinnt dann vor der
# Ziffernform, und eine nummerierte Kennung mit Titel-Suffix
# ("slice-170-archivierungs-werkzeug") liefert die GANZE Kette statt nur der
# Nummer "slice-170".
set -euo pipefail
sed -i 's/slice-(?:\[0-9\]{3}|\[a-z0-9\]+(?:-\[a-z0-9\]+)\*)/slice-(?:[a-z0-9]+(?:-[a-z0-9]+)*|[0-9]{3})/' internal/archive/stub.go
