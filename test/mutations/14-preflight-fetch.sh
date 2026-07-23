#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestRun_FetchKollisionSchreibtNichts
#
# Der Phase-1-Fetch-Pre-Flight prueft nichts mehr (slice-025): fetch.Skeleton legt
# das Skelett ab, EHE fetch.Baseline die vorhandene Baseline bemerkt — der
# Teil-Fetch ist zurueck (.harness/skeleton/ liegt trotz Kollision im Ziel).
set -euo pipefail
# slice-035: die Fetch-Pre-Flight-Ziele stehen in der Variable fetchTargets; der Aufruf
# wird auf eine leere Liste umgebogen -> der Pre-Flight prueft nichts.
sed -i 's|preflightAbsent(targetDir, fetchTargets)|preflightAbsent(targetDir, []string{})|' cmd/ai-harness-init/main.go
