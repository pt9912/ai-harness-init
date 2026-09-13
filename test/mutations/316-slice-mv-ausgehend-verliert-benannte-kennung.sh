#!/usr/bin/env bash
# files: harness/tools/slice-mv.sh
# expect: ausgehend: benannte Slice-Kennung ohne Ziffern-Praefix bekommt ../from/ ebenso wie eine nummerierte
# verify: test-bats
#
# Nimmt rewrite_outgoing_bare_in_file() die Buchstaben-Haelfte des Fundmusters
# zurueck ("[0-9a-z]" -> "[0-9]") — ein praefixloses Ziel mit einer benannten
# (nicht nummerierten) Slice-Kennung faellt dann durch den Fund und bleibt im
# alten Verzeichnis-Bezug stehen, statt auf "../<from>/" umgehaengt zu werden.
set -euo pipefail
sed -i 's/slice-\[0-9a-z\]/slice-[0-9]/' harness/tools/slice-mv.sh
