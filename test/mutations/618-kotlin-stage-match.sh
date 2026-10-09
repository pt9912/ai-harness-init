#!/usr/bin/env bash
# files: internal/gen/kotlin.go
# expect: TestKotlinCodeGateFragment_TargetsMatchStages
#
# Die Dockerfile-Stage `AS test` des Kotlin-Skeletts wird umbenannt -> alle drei
# Fragment-Fassungen rufen `--target test`, aber es gibt keine gleichnamige Stage mehr
# (halluziniertes Gate, LH-QA-01, ADR-0088 §Fitness Function).
set -euo pipefail
sed -i 's/^FROM build AS test$/FROM build AS testx/' internal/gen/kotlin.go
