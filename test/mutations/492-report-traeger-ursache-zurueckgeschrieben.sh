#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestSchreibe_FehlenderAblageortMeldetSichAndersAlsLeerer
# verify: test-go
#
# SCHREIBT DIE TRAEGER-URSACHE IN DIE MELDUNG DES LEEREN BESTANDS ZURUECK: "ein
# frischer Klon hat es nicht, und ein Aufraeum-Lauf nimmt es weg".
#
# Beides kann in dem Zustand, in dem diese Zeile erscheint, nicht zutreffen: fehlte
# das Programm, haette das emittierte Fragment eine Ebene hoeher seine eigene Meldung
# gedruckt und dieses Programm nie gestartet; und span-clean nimmt den BESTAND, nicht
# das Programm. Die Traeger-Ursache gehoert in die Meldung des Fragments, nicht in die
# des leeren Bestands (slice-071 DoD (1)).
set -euo pipefail
sed -i 's@"Werkzeug-Aufruf legt die erste Zeile an\.\\n"@"Werkzeug-Aufruf legt die erste Zeile an — ein frischer Klon hat es nicht, und ein Aufraeum-Lauf nimmt es weg.\\n"@' internal/report/report.go
