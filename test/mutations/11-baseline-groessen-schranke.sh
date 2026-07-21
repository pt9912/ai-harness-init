#!/usr/bin/env bash
# files: internal/fetch/baseline.go
# expect: TestBaseline_AssetTooLarge
#
# Die Groessen-Schranke (slice-022a L4) feuert nie mehr: ein Body ueber
# maxBaselineBytes kommt durch readCapped, statt als AssetTooLargeError abgewiesen
# zu werden — der Pin meldet dann SHA256Mismatch, nicht die Ueberschreitung.
set -euo pipefail
sed -i 's/if int64(len(data)) > limit {/if int64(len(data)) > limit+(1<<62) {/' internal/fetch/baseline.go
