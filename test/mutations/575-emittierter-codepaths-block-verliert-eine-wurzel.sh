#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_EntschiedeneModulListe
#
# Nimmt dem emittierten Block codepaths: die Wurzel harness. Der Waechter bindet die roots
# genau; mit zwei Wurzeln faerbt er rot.
set -euo pipefail
sed -i 's/^  roots: \[spec, docs, harness\]$/  roots: [spec, docs]/' internal/emit/templates/d-check.yml
