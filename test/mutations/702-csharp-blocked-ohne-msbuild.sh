#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestBlockedFragment_CsharpTraegtDieNamenDerAdr
#
# msbuild, nuget und csc verschwinden aus dem blocked/csharp-Fragment -> der naheliegende
# Host-Umweg laeuft im Ziel ungehindert (ADR-0096 Festlegung 6). Das Fragment bleibt nicht-leer;
# der Kopplungs-Test ueber alle gen-Profile bleibt gruen.
set -euo pipefail
sed -i 's/"dotnet msbuild nuget csc\\n",$/"dotnet\\n",/' internal/emit/enforce.go
