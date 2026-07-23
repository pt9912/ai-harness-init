#!/usr/bin/env bash
# files: internal/emit/makefile.go
# expect: TestMakefile_HasOrderEdge
#
# Die Ordnungskante wird aus dem Aggregator (seit slice-035 in emit.Makefile) entfernt:
# `record-gates: $(GATE_CHECKS)` -> `record-gates:` (ohne Prereqs). Dann haengt gates nur
# an record-gates, und die akkumulierten Checks (lint/build/test/docs-check/baseline-verify)
# liefen GAR NICHT (stilles Teilmengen-Gate, LH-QA-01). Der Reihenfolge-Waechter muss rot.
# Real auch im full-smoke sichtbar (alle Marker fehlten), aber der go-Test faengt es netzlos.
set -euo pipefail
# Die Ordnungskante ist die EINZIGE Zeile, die mit "record-gates: " beginnt (der Kommentar
# nennt sie nicht mehr); .* trifft den Prereq, ohne dass ein $(...) in Single-Quotes stehen
# muss (SC2016) — output-identisch zum expliziten Muster.
sed -i 's/^record-gates: .*/record-gates:/' internal/emit/makefile.go
