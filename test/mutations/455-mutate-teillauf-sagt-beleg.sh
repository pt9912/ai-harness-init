#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: die Ausgabe eines gruenen Teillaufs sagt kein Beleg, nennt Schluessel und ok-Faelle
#
# Streicht das „kein" aus der Schlusszeile des Teillaufs: `TEILLAUF <n> von <total> — Beleg`.
# Die Zeile ist die einzige Stelle, an der ein Leser den Teillauf vom vollen Lauf
# unterscheidet; sagt sie „Beleg", laesst sich ein gruener Teillauf als Beleg zitieren.
#
# Anker: der Wortlaut `— kein Beleg (der` steht einmal, in report_partial.
set -euo pipefail
sed -i 's/— kein Beleg (der/— Beleg (der/' harness/tools/mutate.sh
