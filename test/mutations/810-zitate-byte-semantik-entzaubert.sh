#!/usr/bin/env bash
# files: test/spec-zitate.bats
# expect: der Sensor erkennt ein Zitat ueber zwei Kommentarzeilen, faellt ein falsches und ueberliest Kommentare ohne Dateinamen
# verify: test-bats
#
# Entzaubert die Byte-Semantik des Zitat-Sensors: ohne LC_ALL=C rechnet ein
# UTF-8-faehiges `awk` (_HOST-awk, seit slice-labor-gates-host-rezepte laeuft
# make test-bats am Host) index/substr zeichenweise — `substr(rest, s + 3)`
# kuerzt die um 3 BYTES beginnende Zitat-Sequenz nur um ein Zeichen und das
# mehrzeilige Zitat endet um zwei Zeichen frueher. Rot faerbt
# test/spec-zitate.bats, Test 2 (grep ueber den erwarteten Wortlaut).
set -euo pipefail
sed -i 's/^  LC_ALL=C awk /  awk /' test/spec-zitate.bats
