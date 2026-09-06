#!/usr/bin/env bash
# files: harness/tools/history-range-guard.sh
# expect: history-range-guard: --decide-staged mit ungueltigem Wert -> exit 2, fail-closed
#
# Entfernt die Ganzzahl-Wache aus decide_staged() (den
# `case "$has_staged" in ... esac`-Block). Ein Wert ausserhalb 0|1 an
# --decide-staged faellt danach nicht mehr fail-closed mit Exit 2, sondern
# erreicht `[ "$has_staged" -eq 0 ]` direkt: bash meldet dort "Ganzzahliger
# Ausdruck erwartet" auf stderr, liest die Bedingung als falsch und laeuft
# durch, ohne die Meldung auszugeben — Exit 0 statt 2, keine Diagnose.
#
# Der Block beginnt bei "case "$has_staged" in" und endet am naechsten
# "esac" — beide Anker kommen genau einmal vor.
set -euo pipefail
sed -i "/case \"\$has_staged\" in/,/esac/d" harness/tools/history-range-guard.sh
