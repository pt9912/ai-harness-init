#!/usr/bin/env bash
# files: internal/gen/csharp.go
# expect: TestCsharpStages_FuehrenDieKommandosDerAdr
#
# Die lint-Stage des C#-Dockerfiles fuehrt kein `dotnet format` mehr (`RUN true`): das Gate lief
# nie, der IDE0005-Fall der Fitness Function bliebe ungeprueft (ADR-0096 Festlegung 3). Das
# Protokoll im Ziel liest Fall 718.
set -euo pipefail
sed -i 's/^RUN dotnet format --verify-no-changes --no-restore$/RUN true/' internal/gen/csharp.go
