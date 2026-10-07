#!/usr/bin/env bash
# files: internal/emit/werkzeugindex.go
# expect: TestWerkzeugIndex_BerichtNenntNeueTargets
# verify: test-go
#
# BEHANDELT JEDEN LAUF ALS ERSTLAUF.
#
# Danach liest der Lauf den liegenden Werkzeug-Teil nicht als Vergleichsstand, der Bericht
# nennt kein neues Target, und die Meldung auf stdout bleibt bei der Zahlen-Zeile. Der Test
# haelt den Re-Lauf und das neue Fragment gegen die erwartete Liste.
set -euo pipefail
sed -i 's/^\tbericht\.Erstlauf = !vorherDa$/\tbericht.Erstlauf, vorherDa = true, false/' internal/emit/werkzeugindex.go
