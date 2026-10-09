#!/usr/bin/env bash
# files: harness/tools/mutate-auswahl.sh
# expect: auswahl: eine geaenderte Fall-Datei ist gewaehlt
#
# Ein geaenderter oder neuer Fall faellt aus der Menge, wenn seine files-Angabe keine
# geaenderte Datei nennt — der neue Zahn liefe nie (AGENTS.md 3.6).
set -euo pipefail
sed -i 's|if \[ ".f" = "test/mutations/.name.sh" \]; then|if false; then|' harness/tools/mutate-auswahl.sh
