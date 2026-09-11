#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: FEHLER — Rollen-Typ fehlt
# verify: full-smoke
#
# EINE ROLLE GEHT AUF DEM WEG ZUM ZIEL VERLOREN: CanonicalRoles fuehrt nur noch fuenf
# Namen, also schreibt der Bootstrap nur fuenf Typ-Dateien unter .claude/agents/. Die
# QUELLE dieses Repos (internal/emit/templates/agents/*.md) traegt die sechste Datei
# weiterhin — sie wird nur nicht mehr emittiert.
#
# WARUM DIE VOLLE STUFE UND NICHT NUR EIN GO-TEST: der Voll-E2E-Sensor
# (harness/tools/full-smoke.sh, rollen_typen_im_ziel) leitet seine erwartete Liste aus
# GENAU dieser Quelle ab, statt sie selbst zu fuehren oder aus dem bootstrappten Ziel zu
# lesen (letzteres waere zirkulaer und saehe eine fehlende Rolle nie). Dieser Fall ist
# der Zahn ueber dieser Schleife — kein anderer test/mutations/-Fall deckt sie.
set -euo pipefail
sed -i 's@return \[\]string{"planner", "architect", "implementer", "reviewer", "verifier", "validator"}@return []string{"planner", "architect", "implementer", "reviewer", "verifier"}@' internal/span/emit.go
