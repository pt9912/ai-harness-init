#!/usr/bin/env bash
# files: internal/emit/agents.go
# expect: TestAgents_SkipIfPresent
# verify: test-go
#
# STELLT DIE IDEMPOTENZ-KLASSE DER ROLLEN-TYPEN AUF KONVERGENT UM.
#
# Danach schreibt jeder Re-Lauf die sechs Typ-Dateien kanonisch neu. Ein Adopter, der
# seinen Planner-Typ an sein Repo angepasst hat, verliert die Anpassung beim naechsten
# Bootstrap — derselbe Clobber, den ADR-0007 Festlegung 3 fuer die Commands
# ausgeschlossen hat, und der Grund, aus dem ADR-0022 Festlegung 4 den Typen dieselbe
# Klasse gibt.
#
# `test-go` IST DIE SCHMALSTE AUSREICHENDE STUFE: TestAgents_SkipIfPresent misst den
# Emitter direkt und faellt unter dieser Mutation. Der Idempotenz-Lauf in
# harness/tools/full-smoke.sh faellt daneben ebenfalls — er traegt denselben Zahn eine
# Ebene hoeher, ueber dem zweiten Lauf des Produkt-Binaers, und bleibt dort stehen.
set -euo pipefail
sed -i 's/writeSkipIfPresent(targetDir, f.dst, content, f.mode)/writeFileMode(targetDir, f.dst, content, f.mode)/' internal/emit/agents.go
