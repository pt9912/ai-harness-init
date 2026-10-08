#!/usr/bin/env bash
# files: harness/tools/register-ausgang.sh
# expect: register-ausgang: mehr als eine Stand-Zeile ueber der Schwelle -> Befund, auch wenn die erste einen Ausgang nennt
#
# Schaltet die Eindeutigkeits-Pruefung der Zeile `**Stand:**` ab. Dann entscheidet die erste
# Zeile, und eine zitierte Ausgangs-Zeile vor der echten `offen`-Zeile geht still durch.
#
# Rot wird allein der genannte Fall in test/register-ausgang.bats. Anker in DOPPELTEN
# Anfuehrungszeichen (SC2016, s. test/mutations/117).
set -euo pipefail
sed -i "s/if \[ \"\$stand_zeilen\" -gt 1 \]; then/if false; then/" harness/tools/register-ausgang.sh
