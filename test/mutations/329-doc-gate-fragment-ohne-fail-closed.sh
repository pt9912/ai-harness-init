#!/usr/bin/env bash
# files: internal/emit/emit.go
# expect: OHNE die Ziel-Definition GRUEN
# verify: full-smoke
#
# NIMMT DEM EMITTIERTEN FRAGMENT DIE FAIL-CLOSED BEDINGUNG.
#
# Das Fragment haengt den Vorlauf-Waechter als Vorbedingung vor `doc-immutable`/`doc-commits`
# — und prueft vorher, ob das eingebundene d-check.mk das Ziel ueberhaupt definiert. Ohne
# diese Bedingung steht die Vorbindung ueber einem Ziel ohne Rezept: `make doc-immutable`
# endet dann mit Erfolg (Exit 0) und faehrt allein den Waechter, wo der laute Fehlschlag
# "Keine Regel" gehoert.
#
# WARUM `full-smoke` DIE SCHMALSTE AUSREICHENDE STUFE IST: die Zusage gilt dem emittierten
# Fragment in einem gebootstrappten Baum — `make test` faehrt kein Ziel-Makefile, `make
# smoke` faelscht kein d-check.mk. Ein Go-Waechter ueber den Fragment-TEXT waere die
# schmalere Stufe und genau die Klasse aus dem Review-Befund F-1 (ein Anker, der den Text
# prueft statt die Wirkung). Der Preis des Modus steht im Kopf von harness/tools/mutate.sh.
set -euo pipefail
sed -i "s@grep -c '^doc-immutable:' d-check.mk 2>/dev/null || true@echo 1@" internal/emit/emit.go
