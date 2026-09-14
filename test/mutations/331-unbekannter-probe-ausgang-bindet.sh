#!/usr/bin/env bash
# files: internal/emit/emit.go
# expect: waehlte trotz fehlenden Probe-Werkzeugs die Bindung
# verify: full-smoke
#
# LAESST DEN UNBEKANNTEN AUSGANG DES PROBE-WERKZEUGS WIEDER IN DEN PERMISSIVEN ZWEIG FALLEN.
#
# Die fail-closed Bedingung waehlt die Bindung nur bei einem BELEGten Ausgang; fehlt das
# Probe-Werkzeug (awk) im PATH, faellt sie in den Abbruch. Der Operand haengt hinter den
# Probe-Aufruf ein `echo da`: damit traegt auch der unbekannte Ausgang den Marker, und
# `make doc-immutable` endet ueber einem d-check.mk ohne die Ziel-Definition mit Erfolg
# (Exit 0) — die Bindung wird dort gewaehlt, wo der laute Abbruch steht.
#
# WARUM `full-smoke` DIE SCHMALSTE AUSREICHENDE STUFE IST: die Randlage entsteht erst im
# gebootstrappten Baum (das Fragment und sein Aufruf); `make test` faehrt kein Ziel-Makefile.
# Der Preis des Modus steht im Kopf von harness/tools/mutate.sh.
set -euo pipefail
sed -i "s@d-check.mk 2>/dev/null)@d-check.mk 2>/dev/null || echo da)@" internal/emit/emit.go
