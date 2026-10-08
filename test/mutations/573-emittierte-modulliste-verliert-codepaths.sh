#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_EntschiedeneModulListe
#
# Entfernt "codepaths" aus der emittierten modules:-Liste, der Block codepaths: bleibt stehen.
# Der Waechter bindet die Liste genau; ohne codepaths faerbt er rot.
set -euo pipefail
sed -i 's/^modules: \[links, anchors, ids, matrix, codepaths, spans, planning, structure, targets\]$/modules: [links, anchors, ids, matrix, spans, planning, structure, targets]/' internal/emit/templates/d-check.yml
