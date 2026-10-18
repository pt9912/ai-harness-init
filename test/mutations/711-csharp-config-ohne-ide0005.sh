#!/usr/bin/env bash
# files: internal/gen/csharp.go
# expect: TestCsharpConfig_TraegtDieGebundenenZeilen
#
# Die Zeile IDE0005 = error verschwindet aus der emittierten .editorconfig -> ein unbenutztes
# using faerbt weder lint noch build (ADR-0096 Festlegung 3). Die Wirkung im Ziel faehrt Fall 716.
set -euo pipefail
sed -i '/^dotnet_diagnostic\.IDE0005\.severity = error$/d' internal/gen/csharp.go
