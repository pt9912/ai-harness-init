#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestGenerate_AggregatorHasOrderEdge
#
# Die Ordnungskante wird aus dem Aggregator-Makefile entfernt:
# `record-gates: $(GATE_CHECKS)` -> `record-gates:` (ohne Prereqs). Dann haengt gates
# nur an record-gates, und die akkumulierten Checks (lint/build/test/docs-check/
# baseline-verify) liefen GAR NICHT (stilles Teilmengen-Gate, LH-QA-01). Der
# Reihenfolge-Waechter muss rot werden. Real auch im full-smoke sichtbar (alle
# --target-/geprueft-/baseline-Marker fehlten), aber der go-Test faengt es netzlos.
set -euo pipefail
# Die Ordnungskante ist die EINZIGE Zeile, die mit "record-gates: " beginnt (der
# Kommentar nennt sie nicht mehr); .* trifft den $(GATE_CHECKS)-Prereq, ohne dass ein
# $(...) in Single-Quotes stehen muss (SC2016) — output-identisch zum expliziten Muster.
sed -i 's/^record-gates: .*/record-gates:/' internal/gen/golang.go
