#!/usr/bin/env bash
# files: internal/emit/templates_test.go
# expect: courseSet() bildet den realen Template-Satz
#
# Die Test-Fixture verliert einen Eintrag und driftet damit vom realen
# Kurs-Satz ab — das Drift-Paar, das mit dem Embed-Abbau entstand (Befund N-2).
set -euo pipefail
perl -0pi -e 's/\t\t"Makefile":\s*f\("all:\\n\\t\@true\\n"\),\n//' internal/emit/templates_test.go
