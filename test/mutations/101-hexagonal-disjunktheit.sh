#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestArchLayouts_Disjunkt
#
# Zieht das hexagonale Kern-Verzeichnis auf den hexSlice-Namen (`core` -> `domain`) — die
# Bewegung, die ein Aufraeumer macht, der die beiden Layouts fuer zwei Strenge-Grade
# desselben haelt. Danach faellt der hexagonale Kern unter den Schicht-Glob von hexslice:
# aus zwei bewachbaren Layouts wird EINES mit zwei Kanten-Mengen, und die HexSlice-Regeln
# (Slice-Lokalitaet, laterale Trennung) haengen an genau diesen literalen Praefixen.
# CR 0.17.0 und ADR-0010 Festlegung 2 schliessen das aus.
set -euo pipefail
sed -i 's|internal/hexagon/core/|internal/hexagon/domain/|g' internal/gen/golang.go
