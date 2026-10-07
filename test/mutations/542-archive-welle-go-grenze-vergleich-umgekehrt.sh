#!/usr/bin/env bash
# files: internal/archive/grenze.go
# expect: TestGrenzeAltbestandNimmtNurSlicesVorEinerGrenze
# verify: test-go
#
# Kehrt den Abstammungs-Vergleich S <= G um (ADR-0081 Festlegungen 2 und 3): ein
# Slice gilt dann als Vorfahr, wenn die Grenze SEIN Vorfahr ist. Der fruehe Slice
# faellt aus dem Altbestand, und ein Lauf ordnet nach der falschen Richtung der
# Commit-Abstammung ein.
set -euo pipefail
sed -i 's/^\treturn a\.Vorfahren\[g\]\[s\]$/\treturn a.Vorfahren[s][g]/' internal/archive/grenze.go
