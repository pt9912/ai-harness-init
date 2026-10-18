#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestBlockedFragment_CsharpTraegtDieNamenDerAdr
#
# pip wird in das blocked/csharp-Fragment gedoppelt, obwohl der gebackene Boden des Guards es
# fuehrt -> die Union ist nicht mehr die eine Quelle (ADR-0096 Festlegung 6).
set -euo pipefail
sed -i 's/"dotnet msbuild nuget csc\\n",$/"dotnet msbuild nuget csc pip\\n",/' internal/emit/enforce.go
