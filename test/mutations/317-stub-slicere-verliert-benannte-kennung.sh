#!/usr/bin/env bash
# files: internal/archive/stub.go
# expect: TestHervorgegangenUebernimmtBenannteSliceKennung
# verify: test-go
#
# Nimmt sliceRE die Kebab-Case-Alternative zurueck (nur noch slice-NNN) — eine
# Folge-Slice-Kennung ohne Ziffern-Praefix verschwindet dann spurlos aus dem
# Feld Hervorgegangen(), statt als Text zu erscheinen.
set -euo pipefail
sed -i 's/slice-(?:\[0-9\]{3}|\[a-z0-9\]+(?:-\[a-z0-9\]+)\*)/slice-[0-9]{3}/' internal/archive/stub.go
