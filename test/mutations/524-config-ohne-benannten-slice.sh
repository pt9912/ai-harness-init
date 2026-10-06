#!/usr/bin/env bash
# files: .d-check.yml
# expect: kopplung: Traeger und Config tragen dieselbe Muster-Menge
# verify: test-bats
#
# DIE GATE-CONFIG VERLIERT DEN EINTRAG FUER DEN BENANNTEN SLICE: `commits.id-patterns`
# fuehrt danach nur die Nummernform, waehrend der Dogfood-Hook beide Formen annimmt. Das
# Doku-Gate `commits` wiese damit einen Commit zurueck, den der Hook annimmt.
#
# DER PATCH SITZT AUF DEM LISTENEINTRAG der Config, nicht auf der Prosa daneben.
set -euo pipefail
sed -i "/^    - '(^|\[^\[:alnum:\]_-\])slice-\[a-z\]\[a-z0-9-\]\*'\$/d" .d-check.yml
