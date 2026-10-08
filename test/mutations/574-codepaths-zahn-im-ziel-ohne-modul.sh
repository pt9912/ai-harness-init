#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: FEHLER — codepaths-Zahn
# verify: full-smoke
#
# Nimmt der emittierten Konfiguration das Modul codepaths aus der modules:-Liste, der Block
# bleibt stehen. Der codepaths-Zahn (full-smoke.sh) setzt im gebootstrappten Ziel einen
# Inline-Code-Pfad ohne Ziel; ohne das Modul bleibt docs-check gruen, und der Zahn endet
# mit FEHLER.
set -euo pipefail
sed -i 's/^modules: \[links, anchors, ids, matrix, codepaths, spans, planning, structure, targets\]$/modules: [links, anchors, ids, matrix, spans, planning, structure, targets]/' internal/emit/templates/d-check.yml
