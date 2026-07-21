#!/usr/bin/env bash
# files: internal/fetch/baseline.go
# expect: TestBaseline_IncompleteBundle
#
# Der defer raeumt das Temp-Verzeichnis nicht mehr auf (slice-025 L3): bricht
# Baseline NACH MkdirTemp ab (unvollstaendiges Bundle), bleibt ein .baseline-*-Rest
# liegen — assertEmptyDir wird rot.
set -euo pipefail
sed -i 's/defer func() { _ = os.RemoveAll(tmp) }()/defer func() { _ = tmp }()/' internal/fetch/baseline.go
