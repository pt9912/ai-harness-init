#!/usr/bin/env bash
# files: internal/gen/cpp.go
# expect: die Schicht-Header werden nicht gelintet
# verify: full-smoke
#
# Der HeaderFilterRegex der emittierten .clang-tidy wird am Zeilenanfang verankert.
# clang-tidy sieht den Header-Pfad absolut (/src/src/hexagon/...), ein verankertes
# Muster trifft ihn also nie: der Lint-Gate des Ziels prueft dann nur noch
# src/main.cpp, die Schicht-Header bleiben ungeprueft, und ein Verstoss IN der
# Domain-Schicht laesst ihn gruen.
#
# WARUM `full-smoke` die schmalste ausreichende Stufe ist: die Wirkung entsteht erst,
# wenn clang-tidy mit dieser Config real ueber ein gebootstrapptes C++-Modul laeuft.
# `make test` fuehrt den Config-Inhalt nicht aus, und `make smoke` bootstrappt nur
# `--lang go` — beide bleiben unter dieser Mutation gruen, `make full-smoke` faellt.
set -euo pipefail
sed -i "s@HeaderFilterRegex: '(^|/)src/'@HeaderFilterRegex: '^src/'@" internal/gen/cpp.go
