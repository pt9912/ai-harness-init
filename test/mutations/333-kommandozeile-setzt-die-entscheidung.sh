#!/usr/bin/env bash
# files: internal/emit/emit.go
# expect: die Kommandozeile setzte die Entscheidung
# verify: full-smoke
#
# NIMMT DER PROBE DAS OVERRIDE.
#
# Die fail-closed Entscheidung des Fragments ist eine Zusage an den Aufrufer: `make
# DOC_GATE_ZIEL=da doc-immutable` setzt sie nicht ausser Kraft. Traegt die Zuweisung kein
# override, gewinnt die Kommandozeile, und ueber einem d-check.mk ohne die Ziel-Definition
# wird die Bindung gewaehlt — nur der Waechter laeuft, das Modul nicht, Exit 0.
#
# WARUM `full-smoke` DIE SCHMALSTE AUSREICHENDE STUFE IST: die Zusage gilt dem emittierten
# Fragment in einem gebootstrappten Baum, und der Angriff ist der Aufruf selbst. `make test`
# faehrt kein Ziel-Makefile; ein Go-Waechter ueber den Fragment-TEXT pruefte den Text statt
# die Wirkung (AGENTS.md §3.6). Der Preis des Modus steht im Kopf von
# harness/tools/mutate.sh.
set -euo pipefail
sed -i 's@^override DOC_GATE_ZIEL = @DOC_GATE_ZIEL = @' internal/emit/emit.go
