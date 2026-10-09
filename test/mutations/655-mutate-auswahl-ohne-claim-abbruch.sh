#!/usr/bin/env bash
# files: harness/tools/mutate-auswahl.sh
# expect: auswahl: ein fehlender Claim-Commit bricht ab
#
# Ohne Claim-Commit laeuft die Auswahl mit leerer Basis weiter statt abzubrechen (fail-closed,
# LH-QA-01).
set -euo pipefail
sed -i '/\[ -n ".basis" \] || abbruch "kein Claim-Commit/d' harness/tools/mutate-auswahl.sh
