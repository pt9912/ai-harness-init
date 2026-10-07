#!/usr/bin/env bash
# files: internal/emit/makefile.go
# expect: TestMakefile_HasOrderEdge
# verify: test-go
#
# STREICHT DIE ZEILE `-include repo.mk` AUS DEM AGGREGATOR.
#
# Danach liest make die Datei des Repos nicht mehr: ihre Targets fehlen, und ein Gate, das
# sie ueber `GATE_CHECKS +=` anhaengt, laeuft in `make gates` nicht mit (ADR-0080
# Festlegung 3). Der Test haelt die Zeile und ihre Stelle zwischen Glob-Include und
# Ordnungskante. Die Stufe `repo_mk_im_ziel` in harness/tools/full-smoke.sh faellt
# daneben ebenfalls, eine Ebene hoeher im gebootstrappten Ziel.
set -euo pipefail
sed -i '/^-include repo\.mk$/d' internal/emit/makefile.go
