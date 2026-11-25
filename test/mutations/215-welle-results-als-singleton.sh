#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_EmittierterBestandVollstaendig
#
# wave-results.template.md wird in isRecurring nicht mehr erkannt -> sie faellt durch
# bis singletonTarget und landet als docs/plan/planning/wave-results.md im Ziel. Genau
# der Stand vor slice-130: die Vorlage sagt "Kopiere nach docs/plan/planning/done/
# welle-<NN>-results.md" (eine je Welle), am flachen Singleton-Ort loest ihr Verweis
# `](../observations.md)` auf nichts auf. Kompiliert weiter — sonst waere das Rot ein
# Build-Fehler, kein Waechter-Rot.
set -euo pipefail
sed -i 's/"wave-results.template.md", "MR-NNN-title.template.md":/"__welle-results-neutralisiert__.template.md", "MR-NNN-title.template.md":/' internal/emit/templates.go
