#!/usr/bin/env bash
# files: internal/gen/java.go
# expect: TestJavaCodeGateFragment_TargetsMatchStages
#
# Die Dockerfile-Stage `AS test` des Java-Skeletts wird umbenannt -> alle drei
# Fragment-Fassungen rufen `--target test`, aber es gibt keine gleichnamige Stage mehr
# (halluziniertes Gate, LH-QA-01, ADR-0094 §Fitness Function).
set -euo pipefail
sed -i 's/^FROM build AS test$/FROM build AS testx/' internal/gen/java.go
