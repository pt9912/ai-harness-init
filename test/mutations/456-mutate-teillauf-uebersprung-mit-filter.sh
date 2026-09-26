#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: ein Teillauf faehrt trotz stehendem Beleg zum aktuellen Schluessel
#
# Nimmt dem Beleg-Uebersprung in main() die Bedingung „kein Filter": bei stehendem Beleg
# zum aktuellen Schluessel meldet dann auch ein Lauf mit MUTATE_CASES „Beleg liegt vor" und
# faehrt keinen Fall. Der Filter ist eine ausdrueckliche Anfrage, kein Uebersprung.
#
# Anker: `[ -z "$partial" ] && ` steht einmal, in der elif-Bedingung des Uebersprungs; die
# Klammer `[$]` haelt das Dollar aus dem einfach gequoteten Muster (SC2016).
set -euo pipefail
sed -i 's/\[ -z "[$]partial" \] && //' harness/tools/mutate.sh
