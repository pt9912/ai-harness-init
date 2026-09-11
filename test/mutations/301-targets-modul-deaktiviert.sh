#!/usr/bin/env bash
# files: .d-check.yml
# expect: targets ist in modules: aktiviert
#
# Nimmt `targets` aus der `modules:`-Liste — das Modul liegt weiter im gepinnten Image, laeuft
# aber nicht mehr. `docs-check` bleibt dadurch blind gegen ein .PHONY-Rezept ohne Tabellenzeile in
# AGENTS.md und gegen eine `make X`-Tabellenzeile ohne passendes Rezept (0 Befund(e), obwohl der
# Bestand driftet).
set -euo pipefail
sed -i 's/^modules: \[links, anchors, ids, matrix, codepaths, spans, planning, targets\]$/modules: [links, anchors, ids, matrix, codepaths, spans, planning]/' .d-check.yml
