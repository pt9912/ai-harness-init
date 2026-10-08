#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: FEHLER — planning-Gegenbeispiel
# verify: full-smoke
#
# Nimmt der emittierten Konfiguration das Modul planning aus der modules:-Liste, der Block
# bleibt stehen. Die Stufe planning_im_ziel (full-smoke.sh) faehrt beide Richtungen der
# Marker-Invariante am frisch emittierten Ziel; ohne das Modul bleiben beide gruen, und die
# Stufe endet mit FEHLER.
set -euo pipefail
sed -i 's/^modules: \[links, anchors, ids, matrix, spans, planning, structure, targets\]$/modules: [links, anchors, ids, matrix, spans, structure, targets]/' internal/emit/templates/d-check.yml
