#!/usr/bin/env bash
# files: internal/emit/templates/enforce/archivierung.mk
# expect: TestArchivierungFragment_ZielAmTraegerUndNichtInDerGatesKette
# verify: test-go
#
# HAENGT DAS ARCHIVIERUNGS-KOMMANDO AN GATE_CHECKS: `make gates` faehrt danach in
# jedem gebootstrappten Repo die Archivierung.
#
# Das ist die Verwechslung, gegen die das Fragment antritt. Ein Gate ueber einer
# Archivierung prueft nichts — es faerbt rot, wenn das Kommando fehlschlaegt, und
# gruen, ohne etwas ueber den Baum zu sagen. Im Ziel ist der Schaden groesser als
# im Dogfood: die Operation bricht ueber einem unsauberen Arbeitsbaum ab, und ein
# Gate, das am Arbeitsbaum haengt, faellt genau dann, wenn jemand gerade schreibt.
#
# Fall 180 traegt dieselbe Klasse fuer das Erfassungs-Fragment (`span-report` in
# der gates-Kette). Der Gegenstand ist ein anderer: dort ein Bericht, hier die
# schreibende Operation.
#
# WARUM die Go-Stufe die schmalste ausreichende ist: gemessen werden die
# GATE_CHECKS-Kante und die transitive Hull des `gates`-Ziels ueber allen
# Make-Quellen des Ziels, gelesen aus dem Emit. Ein Lauf von `make gates` im Ziel
# braeuchte den gebootstrappten Baum samt Archiven.
set -euo pipefail
sed -i '$a GATE_CHECKS += archive-welle' internal/emit/templates/enforce/archivierung.mk
