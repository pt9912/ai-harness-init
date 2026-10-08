#!/usr/bin/env bash
# files: harness/tools/register-ausgang.sh
# expect: register-ausgang: Wurzel ohne Eintrag unter BEO-*/*/ -> exit 2, kein Gruen ueber leerem Pruefbereich
#
# Schaltet den Abbruch ueber einem leeren Pruefbereich ab. Trifft `BEO-*/*/` kein Verzeichnis,
# endet der Lauf dann mit Exit 0, ohne etwas geprueft zu haben.
#
# Rot wird allein der genannte Fall in test/register-ausgang.bats. Anker in DOPPELTEN
# Anfuehrungszeichen (SC2016, s. test/mutations/117).
set -euo pipefail
sed -i "s/if \[ \"\$eintraege\" -eq 0 \]; then/if false; then/" harness/tools/register-ausgang.sh
