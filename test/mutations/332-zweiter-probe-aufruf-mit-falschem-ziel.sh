#!/usr/bin/env bash
# files: internal/emit/emit.go
# expect: doc-commits nennt den Waechter nicht
# verify: full-smoke
#
# VERTAUSCHT DEN ZIEL-NAMEN IN EINEM DER ZWEI PROBE-AUFRUFE.
#
# Die Probe DOC_GATE_ZIEL steht einmal, und beide Ziele rufen sie mit ihrem eigenen Namen auf.
# Der Operand vertippt den zweiten Aufruf: die Probe findet `doc-commit` nie und waehlt darum
# den Abbruch — auch ueber einem d-check.mk, das `doc-commits` mit Rezept fuehrt. Gefangen
# wird das an der Kette des Ziels: `make -n doc-commits` druckt dann die Abbruch-Regel statt
# der Waechter-Zeile. Damit ist nicht nur die Probe bewacht, sondern auch ihr Aufruf je Ziel.
#
# WARUM `full-smoke` DIE SCHMALSTE AUSREICHENDE STUFE IST: die Verdrahtung entsteht erst im
# gebootstrappten Ziel, `make test` faehrt kein Ziel-Makefile. Der Preis des Modus steht im
# Kopf von harness/tools/mutate.sh.
set -euo pipefail
sed -i "s@\$(call DOC_GATE_ZIEL,doc-commits)@\$(call DOC_GATE_ZIEL,doc-commit)@" internal/emit/emit.go
