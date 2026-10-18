#!/usr/bin/env bash
# files: internal/gen/csharp.go
# expect: full-smoke: FEHLER — make gates nach add-lang csharp ohne Beleg fuer
# verify: full-smoke
#
# Die lint-Stage des C#-Dockerfiles fuehrt kein `dotnet format` mehr (`RUN true`): make gates
# bleibt gruen, das Gate lief aber nicht. Die Go-Tests koppeln nur Stage-NAMEN an das Fragment;
# der Beleg-Marker der Stufe "add-lang csharp apps/csharp" in harness/tools/full-smoke.sh liest
# den Lint-Aufruf im BuildKit-Protokoll (LH-QA-01).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's/^RUN dotnet format --verify-no-changes --no-restore$/RUN true/' internal/gen/csharp.go
