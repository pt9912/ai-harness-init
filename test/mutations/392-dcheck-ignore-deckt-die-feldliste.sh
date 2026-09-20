#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: TestFeldliste_LiegtImGeprueftenBereich
#
# ERWEITERT scan.ignore DER EMITTIERTEN .d-check.yml UM "harness/**": das deckt
# emit.FieldListPath ("harness/erfassung-feldliste.md") — die Feldliste faellt dann aus
# dem geprueften Doku-Bereich des Ziels, obwohl sie dort liegen soll (ADR-0022
# Festlegung 7).
set -euo pipefail
sed -i 's@ignore: \["\*\*/\*\.template\.md", "\.tmp/\*\*", "\.harness/\*\*"\]@ignore: ["**/*.template.md", ".tmp/**", ".harness/**", "harness/**"]@' internal/emit/templates/d-check.yml
