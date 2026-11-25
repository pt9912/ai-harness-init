#!/usr/bin/env bash
# files: .d-check.yml
# expect: pinsync: das Pin d-check paart d-check.mk ueber DCHECK_IMAGE und internal/emit/emit.go ueber DefaultImage
#
# Entfernt die Quellen-Zeile `d-check.mk` aus dem Pin-Block: das Paar haelt dann nur noch die
# Quelle internal/emit/emit.go — die Stellen-Abgleich-Paarung des d-check-Werkzeug-Pins ist
# weg. Rot faerbt der wiring-Test (Config-Zusicherung, kein Docker-Lauf,
# test/pinsync-modul-wiring.bats). Der Verhaltens-Zahn ist davor gemessen: ein verfaelschter
# Pin-Wert an GENAU EINER der beiden Quellen (DCHECK_IMAGE in d-check.mk) faerbt `make
# docs-check` mit dem Grund-Code `pinsync-mismatch` rot (Beleg: harness/sensors/docs-check.md
# §Grenze, Modul pinsync).
set -euo pipefail
sed -i '/- {file: d-check.mk, pattern:/d' .d-check.yml
