#!/usr/bin/env bash
# files: harness/tools/slice-mv.sh
# expect: psed_i: scheitert der sed
# verify: test-bats
#
# NIMMT psed_i DIE SPERRE VOR DEM ZURUECKSCHREIBEN: der `cat` laeuft danach auch
# dann, wenn der `sed` gescheitert ist. Die Zieldatei ist danach auf 0 Byte
# gekuerzt, und der Status ist der des `cat`, also 0 — der Nachzug meldet Erfolg
# ueber einer geleerten Datei.
#
# WAS DAS MISST: der Fall laesst jeden `sed -E` per PATH-Wrapper scheitern und
# ruft psed_i in einer Sub-Shell unter `||`, der Aufrufform aus main(), in der
# `set -e` im Funktionsrumpf nicht gilt. Er liest den Status (2) und den
# Dateiinhalt (unveraendert) getrennt; die Statuszeile faerbt bei dieser Mutation.
#
# Der Anker steht genau einmal im Skript, als Bedingung des `if` in psed_i
# (grep -c 'if sed "[$]@" >"[$]tmp" && cat' harness/tools/slice-mv.sh -> 1).
set -euo pipefail
sed -i 's~if sed "[$]@" >"[$]tmp" && cat "[$]tmp" >"[$]ziel"; then~if { sed "\x24@" >"\x24tmp"; cat "\x24tmp" >"\x24ziel"; }; then~' harness/tools/slice-mv.sh
