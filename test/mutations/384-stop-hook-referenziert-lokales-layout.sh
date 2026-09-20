#!/usr/bin/env bash
# files: internal/emit/templates/enforce/stop-require-gates.sh
# expect: TestEnforce_LangAgnostic
#
# LAESST DEN EMITTIERTEN STOP-HOOK DAS LOKALE harness/tools/-LAYOUT NENNEN statt des
# emittierten tools/harness/ (MR-005). Im Ziel gibt es harness/tools/ nicht — der Hook
# riefe ein Skript auf, das dort nicht liegt.
set -euo pipefail
sed -i 's@tools/harness/working-tree-hash\.sh@harness/tools/working-tree-hash.sh@' internal/emit/templates/enforce/stop-require-gates.sh
