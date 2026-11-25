#!/usr/bin/env bash
# files: Makefile
# expect: gate-nachweis: gates haengt an keinen make-Voraussetzungen (Fast-Pfad-Form)
#
# SEIT ADR-0099 (Fast-Pfad-Form) an die neue Kante gezogen — der Anker misst gegen den
# Quell-Bestand (MR-071): der vormals gemutate Text `gates: record-gates` existiert
# nicht mehr. Ein Voraussetzungs-Check wird am Fast-Pfad-Einsprung gehaengt, statt an
# der Kante: `gates: ## ...` -> `gates: compile ## ...`, waehrend `compile` an der Kante
# fehlt. Das ist die Form, in der das Loch zurueckkommt — ein Check, den make vor dem
# Wrapper baut, ohne dass `record-gates` ihn ueber rotem Stand haeng haette.
#
# `compile` ist ein realer Target dieses Makefile und heute bewusst NICHT in gates
# (schnelles Compile-Feedback); die Mutation ist damit ein Makefile, das make baut,
# kein Syntax-Bruch.
set -euo pipefail
sed -i "s/^gates: ##/gates: compile ##/" Makefile
