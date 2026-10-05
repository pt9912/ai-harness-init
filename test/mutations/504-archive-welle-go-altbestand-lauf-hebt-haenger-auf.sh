#!/usr/bin/env bash
# files: internal/archive/vorschau.go
# expect: TestArchiveWelleAltbestandSperrtImLaufBeiHaenger
# verify: test-go
#
# ADR-0041 Festlegung 4 am SCHREIBENDEN Lauf: der Lauf ueber den Schluessel
# `altbestand` nimmt dieselbe Vorpruefung wie die Vorschau (Fall 310 deckt deren
# Bericht). Die Mutation gibt der haenger-Pruefung die Bedingung der drei
# aufgehobenen Ausgaenge: unter `altbestand` fuehre der Lauf trotz eines
# eingehenden Verweises auf einen verschwindenden Review-Report aus.
set -euo pipefail
sed -i 's/^\tif len(haenger) > 0 {$/\tif welleGebunden \&\& len(haenger) > 0 {/' internal/archive/vorschau.go
