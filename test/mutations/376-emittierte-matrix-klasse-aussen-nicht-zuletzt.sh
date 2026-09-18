#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_EntschiedeneModulListe
#
# Zieht die Klasse aussen vor die Klasse adaptionsblock, ohne sie zu entfernen: Klasse und
# Regel bleiben vorhanden, nur die Ordnung faellt. First-Match heisst, dass eine nicht
# zuletzt stehende ** jeder nachfolgenden Klasse ihre Dateien nimmt und deren Regeln leer
# laufen laesst.
set -euo pipefail
sed -i '/^    - {name: aussen, paths: \["\*\*"\]}$/d' internal/emit/templates/d-check.yml
sed -i 's|^    - {name: adaptionsblock,|    - {name: aussen, paths: ["**"]}\n    - {name: adaptionsblock,|' \
  internal/emit/templates/d-check.yml
