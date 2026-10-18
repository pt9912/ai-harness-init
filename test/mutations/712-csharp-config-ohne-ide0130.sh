#!/usr/bin/env bash
# files: internal/gen/csharp.go
# expect: TestCsharpConfig_TraegtDieGebundenenZeilen
#
# Die Zeile IDE0130 = error verschwindet aus der emittierten .editorconfig -> ein Namensraum, der
# dem Verzeichnis nicht folgt, faerbt nichts, und a-check loest ihn nicht auf (ADR-0096
# Festlegung 3 und 5).
set -euo pipefail
sed -i '/^dotnet_diagnostic\.IDE0130\.severity = error$/d' internal/gen/csharp.go
