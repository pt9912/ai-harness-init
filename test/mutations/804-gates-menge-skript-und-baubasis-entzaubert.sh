#!/usr/bin/env bash
# files: harness/tools/gates-keys.sh
# expect: keys: je Check mit Werkzeug-Skript deckt die Menge ihr eigenes Skript
# verify: test-bats
#
# ENTLEERT ZWEI TAFEL-KORREKTUREN DES SATZERZEUGERS (Plan
# slice-gates-pruefgegenstand-stempel-v1 §3, Messrezept je Check): (1) die
# baseline-verify-Zeile, die das eigene Werkzeug-Skript nennt — ohne sie SKIPpt
# der Fast-Pfad am Skript-Drift des Checks; (2) die host-bin-Eintraege go.mod,
# go.sum und internal/*.go — ohne sie SKIPpt der Fast-Pfad am Bau-Drift, ohne
# den Bau zu fahren (go build kompiliert die cmd-Quellen samt ihrer
# internal-Abhaengigkeiten). Die Deletionen laufen im host-bin-Bereich
# bereichsbeschraenkt (host-bin) bis ;;, damit die gleichlautenden
# lint/build/test-Zeilen unberuehrt bleiben. Faerbt die beiden Wächter in
# test/gates-keys.bats rot: `keys: je Check mit Werkzeug-Skript deckt die Menge
# ihr eigenes Skript` (menge baseline-verify verliert die Skript-Zeile) und
# `keys: die kompilierte Menge des host-bin deckt die Baubasis …`. GRUEN bleibt
# der uebrige Wächter-Satz: leere Menge entsteht durch die Deletionen nicht
# (baseline-verify behaelt den Baum-Glob).
set -euo pipefail
sed -i '/baseline-verify\.sh/d' harness/tools/gates-keys.sh
sed -i "/^    host-bin)\$/,/^[[:space:]]*;;\$/ { /go\\.mod/d; /go\\.sum/d; /internal\\/\\*\\.go/d; }" harness/tools/gates-keys.sh
