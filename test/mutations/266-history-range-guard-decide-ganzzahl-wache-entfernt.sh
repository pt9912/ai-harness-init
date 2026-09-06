#!/usr/bin/env bash
# files: harness/tools/history-range-guard.sh
# expect: history-range-guard: --decide mit nicht-numerischem count -> exit 2, fail-closed
#
# Entfernt die Ganzzahl-Wache aus decide() (den `case "$count" in ... esac`-Block).
# Ein nicht-numerisches drittes Argument an --decide faellt danach nicht mehr
# fail-closed mit Exit 2, sondern erreicht `[ "$count" -eq 0 ]` direkt: bash
# meldet dort "Ganzzahliger Ausdruck erwartet" auf stderr, liest die Bedingung
# als falsch und laeuft in den OK-Zweig — Exit 0 statt 2.
#
# Der Block beginnt bei "case "$count" in" und endet am naechsten "esac"
# (Zeile 96 im ungemutierten Stand); beide Anker kommen im Skript vor der
# zweiten `case`/`esac`-Verwendung (decide_staged) genau einmal vor der
# jeweils naechsten Marke vor.
set -euo pipefail
sed -i "/case \"\$count\" in/,/esac/d" harness/tools/history-range-guard.sh
