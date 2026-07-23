#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestGenerate_GoMkTargetsMatchStages
#
# Die Dockerfile-test-Stage wird umbenannt (test -> testx), aber das Code-Gate-
# Fragment harness/mk/go.mk ruft weiter `--target test` — ein halluziniertes Gate
# (LH-QA-01): ein Target ohne Stage. Der Kopplungstest muss rot werden.
set -euo pipefail
sed -i 's/^FROM deps AS test$/FROM deps AS testx/' internal/gen/golang.go
