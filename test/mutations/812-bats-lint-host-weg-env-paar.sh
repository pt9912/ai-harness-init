#!/usr/bin/env bash
# files: harness/tools/bats-lint.sh
# expect: shell-lint Host-Weg: bats-preprocess erhaelt das BATS_ROOT/BATS_LIBDIR-Paar
# verify: test-bats
#
# Nimmt das Auflagen-Paar vom preprocess-Aufruf des Host-Wegs: bats-preprocess
# sourced common.bash relativ zu $BATS_ROOT/$BATS_LIBDIR und bricht am leeren
# Paar an //bats-core/common.bash — am realen Host laut (rot gesehen vor dem
# Fix, slice-labor-gates-host-rezepte). Der Stub-Test sieht das leere Paar
# (»Paar <> | <>«) und faerbt rot — der Exit-2 bleibt im geaenderten Stand
# ungeaendert laut, nur die Wert-Zusicherung faerbt.
set -euo pipefail
sed -i 's@BATS_ROOT=..bats_root" BATS_LIBDIR=..bats_libdir" @@' harness/tools/bats-lint.sh
