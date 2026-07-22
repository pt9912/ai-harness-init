#!/usr/bin/env bash
# files: internal/wire/wire.go
# expect: TestPlace_PlacesAndWires
#
# Der enforceWiring-Anhang faellt aus wire.Place weg -> das Ziel-Makefile bekommt
# kein `gates: record-gates` mehr, der Gate-Nachweis liefe nie (der emittierte
# Stop-Hook haette keinen Stempel zu vergleichen). Der Waechter TestPlace_PlacesAndWires
# verliert `gates: record-gates` -> rot. Kompiliert weiter: ein ungenutzter
# Package-Const ist in Go kein Fehler.
set -euo pipefail
sed -i '/append(content, enforceWiring/d' internal/wire/wire.go
