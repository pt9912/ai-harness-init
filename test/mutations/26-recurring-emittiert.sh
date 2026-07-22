#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_EmittierterBestandVollstaendig
#
# Eine wiederkehrende Vorlage (slice.template.md) wird in isRecurring nicht mehr
# erkannt -> sie faellt durch bis singletonTarget und wird als docs/plan/planning/
# slice.md emittiert (0.7.0-Rueckfall, LH-FA-02 0.8.0 gebrochen). Der emittierte
# Bestand weicht damit von der Zielmenge ab. Kompiliert weiter (path.Base/isRecurring
# bleiben gerufen) — sonst waere das Rot ein Build-Fehler, kein Waechter-Rot.
set -euo pipefail
sed -i 's/"NNNN-titel.template.md", "slice.template.md", "welle.template.md",/"NNNN-titel.template.md", "__slice-neutralisiert__.template.md", "welle.template.md",/' internal/emit/templates.go
