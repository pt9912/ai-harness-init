#!/usr/bin/env bash
# files: internal/archive/collect.go
# expect: TestSliceNummerTraegtDieBenannteForm
# verify: test-go
#
# Nimmt sliceKennungRE die Namens-Alternative (`slice-<name>.md`, MR-057
# Setzung 1): ein benannter Slice liefert dann die leere Kennung, sein Stub
# traegt `slice-` ohne Namen, und seine Review-Reports bleiben liegen.
set -euo pipefail
sed -i 's/(?:-\[a-z0-9\]+)\*)\\\.md\$)`)/(?:-[a-z0-9]+)*)\\.mdX$)`)/' internal/archive/collect.go
