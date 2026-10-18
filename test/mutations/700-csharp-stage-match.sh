#!/usr/bin/env bash
# files: internal/gen/csharp.go
# expect: TestCsharpCodeGateFragment_TargetsMatchStages
#
# Die Dockerfile-Stage `AS test` des C#-Skeletts wird umbenannt -> alle drei Fragment-Fassungen
# rufen `--target test`, aber es gibt keine gleichnamige Stage mehr (halluziniertes Gate, LH-QA-01,
# ADR-0096 §Fitness Function).
set -euo pipefail
sed -i 's/^FROM toolchain AS test$/FROM toolchain AS testx/' internal/gen/csharp.go
