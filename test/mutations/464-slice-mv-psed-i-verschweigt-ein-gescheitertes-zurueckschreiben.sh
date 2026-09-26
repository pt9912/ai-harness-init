#!/usr/bin/env bash
# files: harness/tools/slice-mv.sh
# expect: psed_i: scheitert das Zurueckschreiben
# verify: test-bats
#
# LAESST psed_i EIN GESCHEITERTES ZURUECKSCHREIBEN VERSCHWEIGEN: der `cat` in die
# Zieldatei scheitert, der Status ist trotzdem 0. Der Nachzug zaehlt die Datei
# als nachgezogen, obwohl ihr Inhalt nicht geschrieben ist.
#
# WAS DAS MISST: der Fall laesst jeden `cat` per PATH-Wrapper scheitern und
# liest den Status von psed_i (2).
#
# Der Anker steht genau einmal im Skript, als zweite Haelfte der Bedingung des
# `if` in psed_i (grep -c '&& cat "[$]tmp" >"[$]ziel"; then' harness/tools/slice-mv.sh -> 1).
set -euo pipefail
sed -i 's~&& cat "[$]tmp" >"[$]ziel"; then~\&\& { cat "\x24tmp" >"\x24ziel" || true; }; then~' harness/tools/slice-mv.sh
