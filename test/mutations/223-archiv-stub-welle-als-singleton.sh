#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_EmittierterBestandVollstaendig
#
# Dieselbe Mutation wie 222, eine Vorlage weiter: archive-stub-wave.template.md wird in
# isRecurring nicht mehr erkannt und landet als docs/plan/planning/archive-stub-wave.md
# im Ziel. Zwei Faelle statt einem, weil jeder der beiden Namen eine eigene
# Klassen-Entscheidung ist — ein Fall auf den Nachbarn bewacht diesen hier nicht.
# Kompiliert weiter — sonst waere das Rot ein Build-Fehler, kein Waechter-Rot.
set -euo pipefail
sed -i 's/"archive-stub-slice.template.md", "archive-stub-wave.template.md",/"archive-stub-slice.template.md", "__archiv-stub-welle-neutralisiert__.template.md",/' internal/emit/templates.go
