#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: FEHLER — Rollen-Typ fehlt
# verify: full-smoke
#
# DIE VERDRAHTUNG FAELLT AUS emitAll: der Aufruf von emit.Agents(targetDir) verschwindet,
# also bleibt .claude/agents/ im Ziel LEER — nicht eine Rolle fehlt, ALLE sechs.
#
# WARUM DIE VOLLE STUFE UND KEIN GO-TEST IM PAKET internal/emit: ein Test dort sieht den
# Aufruf in cmd/ai-harness-init/main.go nicht — emit.Agents bleibt fuer sich genommen
# korrekt, nur ruft sie niemand mehr. Erst ein echter Bootstrap-Lauf zeigt den leeren
# Zielordner. Dieser Fall ist der einzige Zahn ueber dieser Verdrahtung; ohne ihn bleibt
# make test unter dieser Mutation gruen.
set -euo pipefail
sed -i '/if err := emit.Agents(targetDir); err != nil {/,+2d' cmd/ai-harness-init/main.go
