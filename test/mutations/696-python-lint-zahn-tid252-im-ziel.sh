#!/usr/bin/env bash
# files: internal/gen/python.go
# expect: full-smoke: FEHLER — das Python-Lint bleibt bei einem relativen Import gruen
# verify: full-smoke
#
# ban-relative-imports = "all" verschwindet aus der emittierten pyproject.toml. Der Text-Waechter
# (Fall 694) sieht die Zeile; erst der reale ruff-Lauf im gebootstrappten Ziel zeigt, dass
# `from . import main` das Lint nicht mehr faerbt — die Stufe "add-lang python apps/python" in
# harness/tools/full-smoke.sh legt die Probe real an (LH-QA-01, ADR-0095 Festlegung 3).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i '/^ban-relative-imports = "all"$/d' internal/gen/python.go
