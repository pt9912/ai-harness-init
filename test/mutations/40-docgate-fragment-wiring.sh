#!/usr/bin/env bash
# files: internal/emit/emit.go
# expect: TestDocGate_FragmentWiresDocsCheck
#
# Das Doc-Gate-Fragment haengt docs-check-host NICHT mehr an GATE_CHECKS (Zeile ->
# docs-xxx) — im Ziel liefe das Doc-Gate dann nicht in `make gates` mit (stilles
# Teilmengen-Gate, LH-QA-01), obwohl d-check.mk eingebunden bleibt. Der netzlose
# Fragment-Waechter muss rot werden. Ersetzt die Deckung des entfernten Falls 21
# (Doc-Gate-Verdrahtung, frueher via wire-Inline-Include; Review-Befund slice-034 F-1).
# Am Zeilenanfang verankert -> trifft die GATE_CHECKS-Zeile, nicht die Kommentare.
# Anker-Verhalten: der Muster-Text trifft docs-check (das docker-Target), nicht
# docs-check-host — der Prefix-Match haengt an, der Host-Prafix bleibt stehen; der
# Fragment-Waechter (FragmentWiresDocsCheck, Host-Zeile) faellt, und das Doc-Gate
# liefe im Ziel nicht in `make gates` mit (stilles Teilmengen-Gate, LH-QA-01).
# Anker-Nachzug ADR-0109: die Gates-Zeile traegt jetzt docs-check-host.
set -euo pipefail
sed -i 's/^GATE_CHECKS += docs-check-host$/GATE_CHECKS += docs-xxxx/' internal/emit/emit.go
