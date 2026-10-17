#!/usr/bin/env bash
# files: internal/gen/python.go
# expect: TestPythonCodeGateFragment_TargetsMatchStages
#
# Die Dockerfile-Stage `AS test` des Python-Skeletts wird umbenannt -> alle drei
# Fragment-Fassungen rufen `--target test`, aber es gibt keine gleichnamige Stage mehr
# (halluziniertes Gate, LH-QA-01, ADR-0095 §Fitness Function).
set -euo pipefail
sed -i 's/^FROM toolchain AS test$/FROM toolchain AS testx/' internal/gen/python.go
