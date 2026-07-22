#!/usr/bin/env bash
# files: internal/emit/templates/enforce/gitignore
# expect: TestEnforce_GitignoreIgnoresState
#
# Der state/-Ignore verschwindet aus der emittierten .harness/.gitignore -> im Ziel
# zaehlte der record-gates-Stempel selbst in den working-tree-hash, und der Stop-Hook
# blockte sich selbst (jeder Gate-Lauf aendert den Tree, den er gerade stempelt). Das
# ist der subtile Selbst-Blockade-Bug, den das Messen vor dem Code fing.
# TestEnforce_GitignoreIgnoresState wird rot.
set -euo pipefail
sed -i 's#^state/#build/#' internal/emit/templates/enforce/gitignore
