#!/usr/bin/env bash
# files: internal/gen/csharp.go
# expect: TestGenerate_CsharpVersionThreaded
#
# DefaultCsharpVersion erhaelt einen Varianten-Suffix -> kein SDK-Tag der Form
# <major>.<minor>.<patch> mehr; ein anderes Image waere ein anderer Pin (ADR-0096 Festlegung 2).
set -euo pipefail
sed -i 's/^const DefaultCsharpVersion = "10.0.402"$/const DefaultCsharpVersion = "10.0.402-noble"/' internal/gen/csharp.go
