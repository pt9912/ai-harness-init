#!/usr/bin/env bash
# files: internal/fetch/baseline.go
# expect: TestDefaultBaselineSHA256_MatchesMakefile
#
# Der eingebettete Asset-Pin driftet vom kanonischen Makefile-Wert ab. Ohne den
# Kopplungstest bewegte eine Re-Baseline nur eine der beiden Haelften (MR-007).
# Ersetzt den GANZEN Hash statt eines Praefix — sonst veraltet die Mutation beim
# naechsten Re-Baseline (Review-Befund slice-026, LOW).
set -euo pipefail
sed -i 's/^\(const DefaultBaselineSHA256 = "\)[0-9a-f]\{64\}"/\1dead000000000000000000000000000000000000000000000000000000000000"/' internal/fetch/baseline.go
