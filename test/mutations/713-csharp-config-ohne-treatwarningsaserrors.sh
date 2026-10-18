#!/usr/bin/env bash
# files: internal/gen/csharp.go
# expect: TestCsharpConfig_TraegtDieGebundenenZeilen
#
# TreatWarningsAsErrors verschwindet aus Directory.Build.props -> eine unbenutzte Variable
# (CS0219) bleibt gruen (ADR-0096 Festlegung 3).
set -euo pipefail
sed -i '/^    <TreatWarningsAsErrors>true<\/TreatWarningsAsErrors>$/d' internal/gen/csharp.go
