#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_EntschiedeneModulListe
#
# Entfernt order:/direction: no-downward aus der spec-straten-Klasse der emittierten
# .d-check.yml: der Waechter bindet beide Schluessel, nicht nur die drei Klassen-Namen
# — ohne sie faerbt er rot.
set -euo pipefail
sed -i \
  's/, order: \[spec\/lastenheft.md, spec\/spezifikation.md, spec\/architecture.md\], direction: no-downward}/}/' \
  internal/emit/templates/d-check.yml
