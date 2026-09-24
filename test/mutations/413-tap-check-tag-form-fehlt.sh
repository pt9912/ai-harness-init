#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: tag-eingabe: eine Shell-Form im Tag endet mit Exit 2, ohne Ausfuehrung, ohne docker
# verify: test-bats
#
# NIMMT DER TAG-FORM-PRUEFUNG IHRE BEDINGUNG: ein Tag mit Shell-Zeichen laeuft danach
# in die Feldform-Stufe und endet dort mit Exit 2, aber mit der Meldung der Feldform statt
# der Tag-Form. Die Zusage benennt die Ursache; rot faerbt der Fall, der die Meldung liest.
set -euo pipefail
sed -i 's@^if ! \[\[ "[$]tag" =~ [$]tag_form \]\]; then$@if false; then@' harness/tools/tap-nachzug.sh
