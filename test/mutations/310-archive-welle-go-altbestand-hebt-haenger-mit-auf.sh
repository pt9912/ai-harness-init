#!/usr/bin/env bash
# files: internal/archive/vorschau.go
# expect: TestAltbestandBehaeltHaengerSperre
# verify: test-go
#
# ADR-0041 Festlegung 4: der Schluessel aus Festlegung 2 (AltbestandSchluessel)
# hebt vier welle- bzw. untergrenzen-gebundene Ausgaenge auf, `haenger` darf
# nicht mit aufgehen — er traegt die einzige Bindung an die offene Norm-Frage
# ueber Verweis-Nachzug in eingefrorene Artefakte.
#
# Diese Mutation gibt der haenger-Pruefung dieselbe Bedingung wie den drei
# aufgehobenen: unter dem Schluessel 'altbestand' faende der schreibende Lauf
# keine Sperre mehr und archivierte, bevor die Norm-Frage entschieden ist.
set -euo pipefail
sed -i 's/^\tif len(haenger) > 0 {$/\tif welleGebunden \&\& len(haenger) > 0 {/' internal/archive/vorschau.go
