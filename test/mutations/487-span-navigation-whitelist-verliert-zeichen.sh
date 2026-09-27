#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandProgramSkipsNavigationSegments
#
# WHITELIST-GRENZE, VERKUERZT: `plainNavigationChars` fuehrt `%` nicht mehr als schlichtes
# Zeichen. Danach bleibt `cd x%y && make` das Navigations-Segment als Programm: `program`
# nennt `cd` statt `make`. Kein Leck — das Programm bliebe `cd` — aber der Programm-Name geht
# ohne Meldung verloren (SPEC-031).
#
# ROT WIRD DIE TABELLE DER NAVIGATIONS-GRENZE, an der Zeile des Zeichens; `# expect:` nennt
# sie. Sie erzeugt je Zeichen der erwarteten Menge eine Zeile. Der Sweep der unschlichten
# Zeichen erwartet `cd` und bleibt gruen.
set -euo pipefail
sed -i 's@^\(const plainNavigationChars = "\)[$]%@\1$@' internal/span/span.go
