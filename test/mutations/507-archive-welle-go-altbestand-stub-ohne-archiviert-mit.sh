#!/usr/bin/env bash
# files: internal/archive/anwenden.go
# expect: TestArchiveWelleAltbestandSchreibtDieMengeDerVorschau
# verify: test-go
#
# Der Slice-Stub traegt `Archiviert mit: <Schluessel>`. Die Mutation nimmt dem
# Slice-Stub die Ersetzung des Platzhalters `<welle-id>`: das Feld bliebe mit
# dem Platzhalter stehen (Welle-Stub unberuehrt).
set -euo pipefail
sed -i '/^func sliceStub/,/^}/{/^\t\t{"<welle-id>", b\.Welle},$/d}' internal/archive/anwenden.go
