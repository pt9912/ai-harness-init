#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: MUTATE_CASES mit unbekanntem Namen bricht ab, nennt den Namen, kopiert nichts
#
# Nimmt select_cases die Pruefung „es gibt die Fall-Datei": ein unbekannter Name geht dann
# durch, der Filter laesst ihn beim Auswaehlen still fallen, und der Lauf faehrt ueber
# weniger Faellen, als der Aufrufer angefragt hat -- ein Gruen ueber weniger, als es sagt.
#
# Anker: die Bedingung `if [ ! -f "$cases_dir/$name.sh" ]; then` steht einmal, in
# select_cases; `[$]` haelt das Dollar aus dem einfach gequoteten Muster (SC2016).
set -euo pipefail
sed -i 's|if \[ ! -f "[$]cases_dir/[$]name.sh" \]; then|if false; then|' harness/tools/mutate.sh
