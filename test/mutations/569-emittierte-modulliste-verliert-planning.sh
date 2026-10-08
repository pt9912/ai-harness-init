#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_EntschiedeneModulListe
#
# Entfernt "planning" aus der emittierten modules:-Liste, der Block planning: bleibt stehen.
# Der Waechter bindet die Liste genau; ohne planning faerbt er rot.
set -euo pipefail
sed -i 's/^modules: \[links, anchors, ids, matrix, spans, planning, structure, targets\]$/modules: [links, anchors, ids, matrix, spans, structure, targets]/' internal/emit/templates/d-check.yml
