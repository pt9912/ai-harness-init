#!/usr/bin/env bash
# files: internal/gen/csharp.go
# expect: full-smoke: FEHLER — der C#-Build bleibt bei einer nicht-statischen Methode ohne Instanzzugriff gruen
# verify: full-smoke
#
# AnalysisLevel latest-recommended verschwindet aus Directory.Build.props. Die Go-Tests fassen die
# Datei als Text; erst der reale dotnet-build-Lauf der build-Stage im gebootstrappten Ziel zeigt,
# dass CA1822 den Build nicht mehr faerbt — die Stufe "add-lang csharp apps/csharp" in
# harness/tools/full-smoke.sh haengt eine nicht-statische Methode an Program.cs
# (LH-QA-01, ADR-0096 Festlegung 3).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i '/^    <AnalysisLevel>latest-recommended<\/AnalysisLevel>$/d' internal/gen/csharp.go
