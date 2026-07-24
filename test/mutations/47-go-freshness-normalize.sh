#!/usr/bin/env bash
# files: harness/tools/go-freshness.sh
# expect: go-freshness: normalize strippt go-Praefix
#
# Entfernt den `go`-Praefix-Strip in normalize_version (`${first#go}` -> `${first}`):
# die rohe go.dev-Form `go1.26.4` bliebe dann `go1.26.4` statt `1.26.4`. Ohne den
# Fixture-Test (test/go-freshness.bats) faellt die Normalisierung still aus und der
# Nachtlauf verglich `go1.x` gegen den baren Pin -> Dauer-VERALTET (slice-041,
# MR-007). Match-Token `first#go` traegt bewusst KEIN '$' (SC2016-clean) und ist in
# normalize_version eindeutig diese Zeile.
set -euo pipefail
sed -i 's/first#go/first/' harness/tools/go-freshness.sh
