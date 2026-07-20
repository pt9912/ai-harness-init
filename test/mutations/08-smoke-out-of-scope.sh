#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: out-of-scope-Artefakt emittiert
# verify: smoke
#
# Dieselbe inScope-Mutation wie Fall 04, aber gegen den TIER-2-Waechter: fuehrt
# der reale Bootstrap out-of-scope-Artefakte ins Zielrepo, muss `make smoke` rot
# werden. Die smoke-Gegenprobe war bis zum Review inert, weil sie den QUELL-Namen
# prueste (Befund F-2) — und bauartbedingt unbewacht, weil der Treiber nur
# `make test` fuhr (Befund F-5). Beides ist hiermit zu.
set -euo pipefail
sed -i 's/case !strings\.HasSuffix(rel, "\.template\.md"):/case false:/' internal/emit/templates.go
