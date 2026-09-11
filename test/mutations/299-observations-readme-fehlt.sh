#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_EmittierterBestandVollstaendig
#
# planTemplates schreibt den Register-Ort nicht mehr in den Ausgabe-Plan. Der
# emittierte Bestand ist damit unvollstaendig (im realen Emit fehlte
# docs/plan/planning/observations/README.md, obwohl mitemittierte
# Workflow-Commands den Ort bereits als vorhanden referenzieren). Kompiliert
# weiter.
set -euo pipefail
sed -i '/^\tout\[observationsReadmeTarget\] = observationsReadme$/d' internal/emit/templates.go
