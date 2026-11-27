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
#
# PRECONDITION: der Fall roetet nur, wo das geerbte `awk`-Locale
# zeichenrechnet (CI-Runner: C.UTF-8); rechnet das `awk` byte-weise
# (Umgebung LC_ALL=C), bleibt der Lauf gruene Byte-Semantik auch ohne
# LC_ALL=C — gemessen an zwei Locales (`printf '%s' '„test“' | LC_ALL=C awk
# '{print substr($0,5)}'` -> `est“`, `LC_ALL=en_US.UTF-8` -> `t“`).
set -euo pipefail
sed -i 's/^  LC_ALL=C awk /  awk /' test/spec-zitate.bats
