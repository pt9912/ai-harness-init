#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestRun_AddLangDropsModule
#
# Der add-lang-Subkommando-Dispatch wird neutralisiert (Vergleich matcht nie): dann
# faellt `add-lang go apps/api` in den Default-Init statt das Sprachmodul zu droppen —
# das Modul entsteht nicht (slice-037, LH-FA-04). Der Dispatch-Waechter muss rot werden.
set -euo pipefail
sed -i 's/args\[0\] == "add-lang"/args[0] == "add-langXX"/' cmd/ai-harness-init/main.go
