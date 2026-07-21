#!/usr/bin/env bash
# files: internal/wire/wire.go
# expect: TestPlace_PlacesAndWires
#
# Die d-check.mk-Verdrahtung greift ins Leere: der Include zeigt auf eine falsche
# Datei, das generierte Makefile bindet d-check.mk NICHT ein (MR-010) — es gaebe
# zwei Gate-Quellen statt einer.
set -euo pipefail
sed -i 's/include d-check.mk/include d-check-xxx.mk/' internal/wire/wire.go
