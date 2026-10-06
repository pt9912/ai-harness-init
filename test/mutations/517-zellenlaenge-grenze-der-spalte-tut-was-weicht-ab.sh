#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: --- FAIL: TestDCheckConfig_ZellenlaengeStructure
# verify: test-go
#
# Die Grenze der Spalte Tut was im emittierten structure-Block steigt von 200 auf 260 Zeichen:
# der Go-Test bindet beide Spalten auf dieselbe Schwelle 200.
set -euo pipefail
sed -i '/- name: "Tut was"/{n;s/cell-max-chars: 200/cell-max-chars: 260/}' internal/emit/templates/d-check.yml
