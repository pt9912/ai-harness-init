#!/usr/bin/env bash
# files: internal/gen/python.go
# expect: TestPythonLintStage_FuehrtRuffCheckFormatUndMypy
#
# Die lint-Stage des Python-Dockerfiles verliert den mypy-Schritt -> der Typ-Fall der Fitness
# Function (mypy [return-value]) bliebe ungeprueft, ruff check und format laufen weiter
# (ADR-0095 Festlegung 3).
set -euo pipefail
sed -i 's/^RUN ruff check \. && ruff format --check \. && mypy$/RUN ruff check . \&\& ruff format --check ./' internal/gen/python.go
