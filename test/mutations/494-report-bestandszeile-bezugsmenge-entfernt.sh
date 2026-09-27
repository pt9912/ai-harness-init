#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestSchreibe_BestandsZeileNenntIhreBezugsmenge
# verify: test-go
#
# NIMMT DER BESTANDSZEILE IHRE BEZUGSMENGE: sie nennt danach nur noch die Zahl der
# Sitzungen, nicht mehr, WAS gezaehlt wird (verschiedene session-Werte der LESBAREN
# Zeilen).
#
# Die Zahl bleibt richtig, nur ihr Bezug fehlt — derselbe Schaden wie beim fehlenden
# Nenner der Kopfzeile (Fall 140), hier auf die Bestandszeile angewandt
# (slice-071 DoD (3)).
set -euo pipefail
sed -i 's@"Bestand: %d Sitzung(en) — verschiedene session-Werte der lesbaren Zeilen, %s bis %s\\n"@"Bestand: %d Sitzung(en), %s bis %s\\n"@' internal/report/report.go
