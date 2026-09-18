#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestDCheckConfig_EntschiedeneModulListe
#
# Nimmt den ADR-Index aus matrix.exempt-paths der emittierten .d-check.yml. Die Liste
# ist eine EXAKTE Zusicherung, keine Mindestmenge: ein Pfad weniger meldet den Index
# als klassifizierte Quelle, ein Pfad mehr naehme einer Klasse ihre Status-Deckung.
set -euo pipefail
sed -i \
  's|exempt-paths: \["docs/plan/adr/README.md", "docs/reviews/\*\*"\]|exempt-paths: ["docs/reviews/**"]|' \
  internal/emit/templates/d-check.yml
