#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_EntschiedeneModulListe
#
# Entfernt "matrix" aus der emittierten modules:-Liste: der Waechter bindet genau
# [links, anchors, ids, matrix, spans, structure, targets], nicht "mindestens zwei Module" — ohne matrix
# in der Liste faerbt er rot.
set -euo pipefail
sed -i 's/^modules: \[links, anchors, ids, matrix, spans, structure, targets\]$/modules: [links, anchors, ids, spans, structure, targets]/' internal/emit/templates/d-check.yml
