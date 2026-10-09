#!/usr/bin/env bash
# files: harness/tools/mutate-auswahl.sh
# expect: grenze: 8 Faelle ergeben den lokalen Weg
#
# Verschiebt die Schwelle um eins: schon 8 Faelle fuehren auf den CI-Branch statt auf den
# lokalen Lauf (LH-QA-03, Setzung hoechstens 8 lokal).
set -euo pipefail
sed -i 's/\(if \[ ".n" \)-gt\( ".SCHWELLE" \]; then\)/\1-ge\2/' harness/tools/mutate-auswahl.sh
