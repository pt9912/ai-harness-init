#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_EntschiedeneModulListe
#
# Nimmt dem emittierten Block codepaths: die Ausnahme exempt-paths fuer docs/reviews/**.
# Ein Review-Report des Ziels mit einem Pfad, den es nicht mehr gibt, faerbt docs-check
# dann mit codepath-missing rot. Der Waechter bindet den Block samt dieser Zeile; ohne sie
# faerbt er rot.
set -euo pipefail
sed -i '/^  roots: \[spec, docs, harness\]$/{n;/^  exempt-paths: \["docs\/reviews\/\*\*"\]$/d;}' internal/emit/templates/d-check.yml
