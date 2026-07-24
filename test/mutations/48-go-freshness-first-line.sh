#!/usr/bin/env bash
# files: harness/tools/go-freshness.sh
# expect: nimmt erste Zeile
#
# Entfernt die Erste-Zeile-Wahl in normalize_version (`head -n 1` -> `cat`): die
# rohe go.dev-Antwort ist mehrzeilig (`go1.26.5\ntime …`), ohne head-1 bliebe die
# time-Zeile im Output haengen. Schwester zu Fall 47 (go-Strip); zusammen bewachen
# beide Normalisierungs-Schritte, den Plan-§3 als "go-Strip / head -1" nennt
# (Review-INFO-1: die head-1-Zeile war behavioral gedeckt, aber ohne eigenen
# Mutations-Fall — kuratiert heisst unvollstaendig). Match-Token `head -n 1` traegt
# kein '$' (SC2016-clean) und ist eindeutig diese Zeile (slice-041, MR-007).
set -euo pipefail
sed -i 's/head -n 1/cat/' harness/tools/go-freshness.sh
