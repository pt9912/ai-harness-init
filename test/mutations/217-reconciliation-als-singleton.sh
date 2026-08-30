#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_EmittierterBestandVollstaendig
#
# reconciliation.template.md wird in isBrownfieldOnly nicht mehr erkannt -> jedes
# frische Repo bekommt docs/plan/planning/reconciliation.md, waehrend die mitemittierte
# docs/plan/planning/README.md sagt "Greenfield-Repos haben die Datei nicht". Der
# Selbstwiderspruch im emittierten Stand, den die Weiche seit slice-130 ausschliesst.
# Kompiliert weiter.
set -euo pipefail
sed -i 's|return rel == "docs/plan/planning/reconciliation.template.md"|return rel == "docs/plan/planning/__reconciliation-neutralisiert__.template.md"|' internal/emit/templates.go
