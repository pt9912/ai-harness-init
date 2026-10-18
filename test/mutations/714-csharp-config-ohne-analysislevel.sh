#!/usr/bin/env bash
# files: internal/gen/csharp.go
# expect: TestCsharpConfig_TraegtDieGebundenenZeilen
#
# AnalysisLevel latest-recommended verschwindet aus Directory.Build.props -> eine nicht-statische
# Methode ohne Instanzzugriff (CA1822) faerbt den Build nicht mehr (ADR-0096 Festlegung 3). Die
# Wirkung im Ziel faehrt Fall 717.
set -euo pipefail
sed -i '/^    <AnalysisLevel>latest-recommended<\/AnalysisLevel>$/d' internal/gen/csharp.go
