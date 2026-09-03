#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_EmittierterBestandVollstaendig
#
# archiv-stub-slice.template.md wird in isRecurring nicht mehr erkannt -> sie faellt
# durch bis singletonTarget und landet als docs/plan/planning/archiv-stub-slice.md im
# Ziel. Die Vorlage nennt ihren Ort aber als Verzeichnis mit Platzhalter
# (docs/plan/planning/done/<welle-id>/, ein Stub je archiviertem Slice); ein flaches
# Singleton daneben ist ein Ziel, das die Vorlage nirgends zusagt. Kompiliert weiter —
# sonst waere das Rot ein Build-Fehler, kein Waechter-Rot.
set -euo pipefail
sed -i 's/"archiv-stub-slice.template.md", "archiv-stub-welle.template.md",/"__archiv-stub-slice-neutralisiert__.template.md", "archiv-stub-welle.template.md",/' internal/emit/templates.go
