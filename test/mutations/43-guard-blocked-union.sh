#!/usr/bin/env bash
# files: internal/emit/templates/enforce/pretooluse-command-guard.sh
# expect: TestEnforce_GuardBakedFloorAndUnion
#
# Der blocked/*-Union-Read wird gebrochen (blocked_dir= -> blocked_dirx=). Dann liest der
# Guard das blocked/-Verzeichnis nicht mehr — add-lang-Fragmente (blocked/<sprache>) blieben
# im Ziel wirkungslos, die Sprach-Toolchain liefe ungehindert. Der Guard-Waechter (er prueft
# blocked_dir=) muss rot werden.
set -euo pipefail
sed -i 's/blocked_dir=/blocked_dirx=/' internal/emit/templates/enforce/pretooluse-command-guard.sh
