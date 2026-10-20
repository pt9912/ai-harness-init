#!/usr/bin/env bash
# files: harness/tools/traeger-pins-check.sh
# expect: paarung nach name
# verify: test-bats
#
# PAART NACH ZEILENPOSITION STATT NACH NAME: statt den Eintrag mit dem Dateinamen des Assets
# zu suchen, nimmt der Vergleich die Zeile an der Stelle des Plattform-Index in der
# SHA256SUMS. Eine SHA256SUMS in anderer Zeilenfolge als die Plattform-Folge des Skripts
# (sha256sum sortiert alphabetisch; ein Manifest anderer Herkunft muss das nicht) wird dann
# gegen die falschen Pins gehalten.
# Rot faerbt der Fall "paarung nach name", dessen Fixture die Zeilen in anderer Folge fuehrt und
# Exit 0 verlangt. Der Test haelt die Paarungs-Logik, nicht den realen Pin.
set -euo pipefail
sed -i 's~^\ttreffer="\$(printf .%s\\n. "\$sums" | awk -v a="\$asset" .\$2 == a { print \$1 }.)"$~\tnr=\$((nr + 1)); treffer="\$(printf \x27%s\\n\x27 "\$sums" | awk -v i="\$nr" \x27NR == i { print \$1 }\x27)"~' harness/tools/traeger-pins-check.sh
