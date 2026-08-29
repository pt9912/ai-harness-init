#!/usr/bin/env bash
# files: Makefile
# expect: gate-nachweis: gates zieht den Gate-Nachweis ueber record-gates
#
# `gates` zieht den Nachweis nicht mehr: `gates: record-gates` -> `gates:`. Die Kante
# bliebe stehen, und „kein Stempel ueber rotem Lauf" waere erfuellt — dadurch, dass gar
# kein Stempel mehr entsteht. Der Stop-Hook faende dann nie einen passenden Hash und
# blockte jeden Abschluss; die Mechanik waere nicht repariert, sondern abgeschaltet.
# Ohne diesen Fall waere die Erfuellung-durch-Wegfall unbewacht.
set -euo pipefail
sed -i 's/^gates: record-gates.*/gates:/' Makefile
