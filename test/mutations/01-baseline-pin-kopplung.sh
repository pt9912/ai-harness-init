#!/usr/bin/env bash
# files: internal/fetch/baseline.go
# expect: TestDefaultBaselineSHA256_MatchesMakefile
#
# Der eingebettete Asset-Pin driftet vom kanonischen Makefile-Wert ab. Ohne den
# Kopplungstest bewegte eine Re-Baseline nur eine der beiden Haelften (MR-007).
set -euo pipefail
perl -pi -e 's/^(const DefaultBaselineSHA256 = ")123e/${1}dead/' internal/fetch/baseline.go
