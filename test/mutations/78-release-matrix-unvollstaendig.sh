#!/usr/bin/env bash
# files: Makefile
# expect: die Plattform-Liste deckt GENAU die Matrix des Lastenhefts
#
# Streicht die arm64-Haelfte aus der Plattform-Liste. Das Release lieferte dann nur
# noch drei statt sechs Binaries — waehrend LH-QA-04 unveraendert sechs zusagt. Die
# Luecke faellt nicht beim Bau auf (drei Builds laufen sauber durch), sondern erst
# beim Anwender auf arm64. Der Waechter koppelt die Liste an die Anforderung.
set -euo pipefail
sed -i 's| linux/arm64||; s| darwin/arm64||; s| windows/arm64||' Makefile
