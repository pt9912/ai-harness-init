#!/usr/bin/env bash
# files: internal/gen/python.go
# expect: full-smoke: FEHLER — make gates nach add-lang python ohne Beleg fuer
# verify: full-smoke
#
# Die lint-Stage des Python-Dockerfiles fuehrt keinen ruff-/mypy-Schritt mehr (`RUN true`):
# make gates bleibt gruen, das Gate lief aber nicht. Die Go-Tests koppeln nur Stage-NAMEN an
# das Fragment; der Beleg-Marker der Stufe "add-lang python apps/python" in
# harness/tools/full-smoke.sh liest den Lint-Aufruf im BuildKit-Protokoll (LH-QA-01).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's/^RUN ruff check \. && ruff format --check \. && mypy$/RUN true/' internal/gen/python.go
