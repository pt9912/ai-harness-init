#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: tag-form: jedes Zeichen ausserhalb von [0-9A-Za-z.-] im Vorab- oder Build-Feld
# verify: test-bats
#
# NIMMT DER TAG-FORM IHREN ANFANGSANKER: ein Praefix vor dem `v` (`xv1.0.0`) geht danach
# durch die Form und endet erst in der Feldform-Stufe, mit deren Meldung statt der der
# Tag-Form. Rot faerbt der Fall, der fuer jeden Tag die Meldung der Tag-Form liest.
set -euo pipefail
sed -i "s|^tag_form='[\^]v|tag_form='v|" harness/tools/tap-nachzug.sh
