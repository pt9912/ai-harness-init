#!/usr/bin/env bash
# files: internal/emit/templates/enforce/slice-mv.mk
# expect: TestSliceMvFragment_LiegtImZielUndHaengtNichtAnDerGatesKette
# verify: test-go
#
# HAENGT DEN LIFECYCLE-WECHSEL AN GATE_CHECKS: `make gates` faehrt danach in jedem
# gebootstrappten Repo den Move.
#
# Das ist die Verwechslung, gegen die das Fragment antritt. Ein Gate ueber einem
# Move prueft nichts — es faerbt rot, wenn der Move fehlschlaegt, und gruen, ohne
# etwas ueber den Baum zu sagen. Im Ziel ist der Schaden groesser als im Dogfood:
# die Operation bricht ueber einem unsauberen Arbeitsbaum ab, und ein Gate, das am
# Arbeitsbaum haengt, faellt genau dann, wenn jemand gerade schreibt.
#
# Fall 180 und 337 tragen dieselbe Klasse fuer die Fragmente der Erfassungs- und
# der Archivierungs-Schicht; der Gegenstand ist hier ein dritter: der Wechsel.
#
# WARUM die Go-Stufe die schmalste ausreichende ist: gemessen werden die
# GATE_CHECKS-Kante und die transitive Hull des `gates`-Ziels ueber allen
# Make-Quellen des Ziels, gelesen aus dem Emit. Ein Lauf von `make gates` im Ziel
# braeuchte den gebootstrappten Baum samt seinem Dokumentenbestand.
set -euo pipefail
sed -i '$a GATE_CHECKS += slice-mv' internal/emit/templates/enforce/slice-mv.mk
