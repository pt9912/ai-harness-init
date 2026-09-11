#!/usr/bin/env bash
# files: .d-check.yml
# expect: targets ist in modules: aktiviert
#
# Nimmt `targets` aus der `modules:`-Liste — das Modul liegt weiter im gepinnten Image, laeuft
# aber nicht mehr. `docs-check` bleibt dadurch blind gegen ein .PHONY-Rezept ohne Tabellenzeile in
# AGENTS.md und gegen eine `make X`-Tabellenzeile ohne passendes Rezept (0 Befund(e), obwohl der
# Bestand driftet).
#
# Das Muster ankert auf dem TOKEN `, targets` innerhalb der `modules:`-Zeile, nicht auf der
# vollen Liste samt Nachbarn -- dieselbe Anker-Form wie 269/279, verhindert dieselbe Klasse von
# NO-OP nach der naechsten Modul-Aenderung.
set -euo pipefail
sed -i '/^modules: \[/ s/, targets\b//' .d-check.yml
