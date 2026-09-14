#!/usr/bin/env bash
# files: internal/emit/emit.go
# expect: OHNE die Ziel-Definition GRUEN
# verify: full-smoke
#
# NIMMT DEM EMITTIERTEN FRAGMENT DIE FAIL-CLOSED ENTSCHEIDUNG.
#
# Das Fragment haengt den Vorlauf-Waechter als Vorbedingung vor `doc-immutable`/`doc-commits`
# — und prueft vorher, ob das eingebundene d-check.mk das Ziel MIT REZEPT definiert. Der
# Operand ersetzt die EINE Probe (DOC_GATE_ZIEL) durch ein festes "da": der intakte Baum
# bleibt damit gesund (die Bindung wird gewaehlt), und ueber einer Datei OHNE die
# Ziel-Definition wird sie ebenfalls gewaehlt. `make doc-immutable` endet dort mit Erfolg
# (Exit 0) und faehrt allein den Waechter, wo der laute Abbruch steht.
#
# WARUM `full-smoke` DIE SCHMALSTE AUSREICHENDE STUFE IST: die Zusage gilt dem emittierten
# Fragment in einem gebootstrappten Baum — `make test` faehrt kein Ziel-Makefile, `make smoke`
# faelscht kein d-check.mk. Ein Go-Waechter ueber den Fragment-TEXT waere die schmalere Stufe
# und genau ein Anker, der den Text prueft statt die Wirkung (AGENTS.md §3.6). Der Preis des
# Modus steht im Kopf von harness/tools/mutate.sh.
set -euo pipefail
sed -i "s@^DOC_GATE_ZIEL = .*@DOC_GATE_ZIEL = da@" internal/emit/emit.go
