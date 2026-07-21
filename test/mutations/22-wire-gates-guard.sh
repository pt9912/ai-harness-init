#!/usr/bin/env bash
# files: internal/wire/wire.go
# expect: TestPlace_NoGatesTarget
#
# Die Vorbedingung "Skelett-Makefile MUSS ein gates-Target haben" feuert nie: ein
# Makefile ohne gates wird akzeptiert, `gates: docs-check` definierte gates dann
# OHNE die Go-Gates (still leere Verdrahtung).
set -euo pipefail
sed -i 's/if !bytes.Contains(mk/if false \&\& !bytes.Contains(mk/' internal/wire/wire.go
