#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: ein Teillauf mit Befund laesst einen stehenden Beleg byte-gleich stehen
#
# Nimmt die Bedingung von der Sofort-Entwertung in main(): `clear_belief` laeuft dann auch
# im Teillauf. Ein Nachsehen-Lauf ueber einen einzelnen Fall loeschte den Beleg des letzten
# VOLLEN Laufs -- der Vorgang, den der Filter vermeiden soll.
#
# Anker: die Zeile mit `|| clear_belief` (zwei Leerzeichen Einrueckung) ist die einzige
# bedingte Entwertung in main(); die Definition `clear_belief() {` traegt kein `||`.
set -euo pipefail
sed -i 's/^  \[ -n .* || clear_belief$/  clear_belief/' harness/tools/mutate.sh
