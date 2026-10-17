#!/usr/bin/env bash
# files: internal/gen/python.go
# expect: full-smoke: FEHLER — das Python-Lint bleibt bei einem unbenutzten Import gruen
# verify: full-smoke
#
# F verschwindet aus select der emittierten pyproject.toml. Die Go-Tests fassen die Config als
# Text; erst der reale ruff-Lauf der lint-Stage im gebootstrappten Ziel zeigt, dass ein
# unbenutzter Import das Lint nicht mehr faerbt — die Stufe "add-lang python apps/python" in
# harness/tools/full-smoke.sh nimmt ihn real auf (LH-QA-01, ADR-0095 Festlegung 3).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's/"E", "F", "I", "B", "TID"/"E", "I", "B", "TID"/' internal/gen/python.go
