#!/usr/bin/env bash
# files: internal/emit/emit.go
# expect: TestDocGate_FragmentWiresDocsCheck
#
# Das Doc-Gate-Fragment haengt docs-check NICHT mehr an GATE_CHECKS (docs-check ->
# docs-xxx) — im Ziel liefe das Doc-Gate dann nicht in `make gates` mit (stilles
# Teilmengen-Gate, LH-QA-01), obwohl d-check.mk eingebunden bleibt. Der netzlose
# Fragment-Waechter muss rot werden. Ersetzt die Deckung des entfernten Falls 21
# (Doc-Gate-Verdrahtung, frueher via wire-Inline-Include; Review-Befund slice-034 F-1).
# Am Zeilenanfang verankert -> trifft die GATE_CHECKS-Zeile, nicht die Kommentare.
set -euo pipefail
sed -i 's/^GATE_CHECKS += docs-check/GATE_CHECKS += docs-xxx/' internal/emit/emit.go
