#!/usr/bin/env bash
# files: internal/emit/templates_test.go
# expect: courseSet() bildet den realen Template-Satz
#
# Die Test-Fixture verliert einen Eintrag und driftet damit vom realen
# Kurs-Satz ab — das Drift-Paar, das mit dem Embed-Abbau entstand (Befund N-2).
set -euo pipefail
sed -i '/^\t\t"Makefile":/d' internal/emit/templates_test.go
