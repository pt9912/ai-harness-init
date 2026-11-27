#!/usr/bin/env bash
# files: internal/emit/emit.go
# expect: TestDocGate_FragmentWiresDocsCheck
#
# Das Doc-Gate-Fragment haengt docs-check-host GANZZEILIG an GATE_CHECKS
# (dokumentiertes Format: `GATE_CHECKS += docs-check-host`). Der Fall loest die
# EINE gates-Kette-Zeile (Zeilenanfang + Zeilenende verankert — trifft die
# GATE_CHECKS-Zeile, nicht die Kommentare), ersetzt sie durch docs-xxx, und der
# Fragment-Waechter wird rot.
#
# Grenze/Kopplung: der `$`-Anker haelt den Host-Prafix von `docs-check` (docker-
# Weg, opt-in, Rezept im eingebundenen d-check.mk) getrennt — die zwei Target-Namen
# sind Praefix-Paare; ein Muster ohne Zeilenende faerbt den falschen Zahn.
# Ohne die Zeile liefert das Doc-Gate nicht mit in `make gates` (stilles
# Teilmengen-Gate, LH-QA-01).
# Herkunft: ersetzt die Deckung des entfernten Falls 21 (Doc-Gate-Verdrahtung; der
# Anker am wire-Inline-Include liegt in git).
set -euo pipefail
sed -i 's/^GATE_CHECKS += docs-check-host$/GATE_CHECKS += docs-xxxx/' internal/emit/emit.go
