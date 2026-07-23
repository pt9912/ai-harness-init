#!/usr/bin/env bash
# files: internal/gen/cpp.go
# expect: TestCppCodeGateFragment_TargetsMatchStages
#
# Die Dockerfile-Stage `AS test` wird umbenannt -> das cpp-Fragment ruft `--target test`,
# aber es gibt keine gleichnamige Stage mehr (halluziniertes Gate, LH-QA-01). Der
# Stage-Match-Waechter muss rot werden.
set -euo pipefail
sed -i 's/FROM build AS test/FROM build AS testx/' internal/gen/cpp.go
