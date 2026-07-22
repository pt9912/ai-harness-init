#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_EmittierterBestandVollstaendig
#
# Der ADR-Index wird in isDerivativeIndex nicht mehr erkannt -> er wird als
# docs/plan/adr/README.md emittiert (Fuelle-wenn-Inhalt-da verletzt; sein
# Platzhalter-Link braeche docs-check out-of-the-box). Der emittierte Bestand
# weicht damit von der Zielmenge ab. Kompiliert weiter.
set -euo pipefail
sed -i 's|case "docs/plan/adr/README.template.md", "docs/plan/carveouts/README.template.md":|case "docs/plan/adr/__neutralisiert__.template.md", "docs/plan/carveouts/README.template.md":|' internal/emit/templates.go
