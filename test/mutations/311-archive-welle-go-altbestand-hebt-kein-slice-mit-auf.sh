#!/usr/bin/env bash
# files: internal/archive/vorschau.go
# expect: TestAltbestandSperrtBeiKeinSlice
# verify: test-go
#
# Kalibrierung der aufgehobenen Menge (ADR-0041 Folgepflicht 1): genau vier
# Ausgaenge haengen am Schluessel aus Festlegung 2 — ergebnisnotiz, kein-plan,
# mehrdeutiger-plan, untergrenze. `kein-slice` gehoert nicht dazu: ein
# Schluessel ohne Welle, der nichts einsammelt, ist so wenig ein Vorgang wie
# eine Welle ohne Slices.
#
# Diese Mutation weitet die Bedingung auf `kein-slice` aus, als waere er
# ebenfalls welle-gebunden — unter 'altbestand' faende ein leerer Bestand dann
# keine Sperre mehr.
set -euo pipefail
sed -i 's/^\tif len(b.Slices()) == 0 {$/\tif welleGebunden \&\& len(b.Slices()) == 0 {/' internal/archive/vorschau.go
