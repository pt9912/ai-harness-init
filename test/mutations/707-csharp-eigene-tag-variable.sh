#!/usr/bin/env bash
# files: internal/gen/csharp.go
# expect: TestCsharpCodeGateFragment_EigeneTagVariable
#
# Das C#-Fragment setzt seinen Tag unter dem Namen PYTHON_TAG, den das Python-Fragment mit `?=`
# ebenfalls setzt -> der erste gelesene Wert gaelte fuer beide Sprachen, SKEL_CSHARP_VERSION waere
# kein eigener Knopf (ADR-0096 Festlegung 2).
set -euo pipefail
sed -i 's/^DOTNET_TAG ?=/PYTHON_TAG ?=/' internal/gen/csharp.go
