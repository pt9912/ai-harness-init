#!/usr/bin/env bash
# files: Makefile
# expect: DEST ist Pflicht
#
# Nimmt die DEST-Pflicht aus dem Matrix-Target. Ohne Zielverzeichnis kopierte das
# Recipe die Binaries an einen unbeabsichtigten Ort (leerer Pfad), statt mit Exit 2
# als Aufruf-Fehler abzubrechen — dieselbe Zusage, die das bestehende artifact-Target
# traegt. Anker dollar-frei gehalten bzw. escapt (SC2016): der Bereich des Targets
# plus die Pflicht-Meldung, die dort genau einmal vorkommt.
set -euo pipefail
sed -i "/^release-artifacts:/,/^\$/ s|@test -n .*ist Pflicht.*|@true|" Makefile
