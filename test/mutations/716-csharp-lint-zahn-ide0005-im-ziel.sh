#!/usr/bin/env bash
# files: internal/gen/csharp.go
# expect: full-smoke: FEHLER — das C#-Lint bleibt bei einem unbenutzten using gruen
# verify: full-smoke
#
# IDE0005 = error verschwindet aus der emittierten .editorconfig. Die Go-Tests fassen die Config
# als Text; erst der reale dotnet-format-Lauf der lint-Stage im gebootstrappten Ziel zeigt, dass
# ein unbenutztes using das Lint nicht mehr faerbt — die Stufe "add-lang csharp apps/csharp" in
# harness/tools/full-smoke.sh nimmt es real auf (LH-QA-01, ADR-0096 Festlegung 3).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i '/^dotnet_diagnostic\.IDE0005\.severity = error$/d' internal/gen/csharp.go
