#!/usr/bin/env bash
# files: internal/archive/collect.go
# expect: TestKlasseVonFremdBleibtLiegen
# verify: test-go
#
# Nimmt der Einsammel-Regel ihre dritte Klasse — die Umkehr-Richtung: was keine
# Welle nennt oder eine ANDERE, gilt danach als Mitglied. Das ist der teuerste
# der drei Fehler: die Vorschau zoege fremde Slices und deren Review-Reports in
# den Blast-Radius, und der schreibende Lauf archivierte Arbeit, die nie zu
# dieser Welle gehoerte.
set -euo pipefail
sed -i 's/^\treturn Fremd$/\treturn Mitglied/' internal/archive/collect.go
