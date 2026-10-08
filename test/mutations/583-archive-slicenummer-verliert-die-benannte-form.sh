#!/usr/bin/env bash
# files: internal/archive/collect.go
# expect: TestSliceNummerTraegtDieBenannteForm
# verify: test-go
#
# Macht die Namens-Alternative von sliceKennungRE (`slice-<name>.md`, MR-057
# Setzung 1) unerfuellbar: ein benannter Slice liefert dann die leere Kennung, sein Stub
# traegt `slice-` ohne Namen, und seine Review-Reports bleiben liegen.
set -euo pipefail
sed -i 's/|(\[a-z\]\[a-z0-9\]\*(?:/|(A[a-z0-9]*(?:/' internal/archive/collect.go
