#!/usr/bin/env bash
# files: Makefile
# expect: rezept: mutate-branch reicht den Ref als Wert durch, nicht als Shelltext
#
# Das Rezept bettet den Ref wieder als '…'-Literal in den Shelltext ein: ein Branch-Name mit
# ' bricht aus und fuehrt Shell-Code im Job aus, bevor das Skript ihn prueft (MR-014).
set -euo pipefail
sed -i "s/  lauf) bash harness\/tools\/mutate-auswahl.sh lauf \"\\\$\\\$REF\" ;;/  lauf) bash harness\/tools\/mutate-auswahl.sh lauf '\$(REF)' ;;/" Makefile
