#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_ObservationsReadmeSkipIfPresent
#
# Die Idempotenz-Klasse skip-if-present (ADR-0037 Festlegung 3) wird fuer genau den
# Register-Ort auf konvergent umgebogen: ein adopter-gefuelltes
# docs/plan/planning/observations/README.md wird bei einem Re-Lauf ueberschrieben statt
# unberuehrt zu bleiben. Kompiliert weiter (observationsReadmeTarget ist bereits
# Paket-Deklaration).
set -euo pipefail
sed -i \
  's#write := writeSkipIfPresent#write := writeSkipIfPresent\n\t\tif rel == observationsReadmeTarget {\n\t\t\twrite = writeFileMode\n\t\t}#' \
  internal/emit/templates.go
