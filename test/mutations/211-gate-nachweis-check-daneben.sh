#!/usr/bin/env bash
# files: Makefile
# expect: gate-nachweis: kein Check steht neben record-gates
#
# Ein Check wird NEBEN den Nachweis gehaengt, statt an ihn: `gates: record-gates` ->
# `gates: compile record-gates`, waehrend `compile` an der Kante fehlt. Das ist die
# Form, in der das Loch zurueckkommt, ohne dass die Kante verschwindet — der naechste
# neue Gate, den jemand an der alten Stelle eintraegt. Unter `-k` liefe `compile` neben
# record-gates, faellt es, entstuende der Stempel trotzdem.
#
# `compile` ist ein realer Target dieses Makefile und heute bewusst NICHT in gates
# (schnelles Compile-Feedback); die Mutation ist damit ein Makefile, das make baut,
# kein Syntax-Bruch.
set -euo pipefail
sed -i 's/^gates: record-gates/gates: compile record-gates/' Makefile
