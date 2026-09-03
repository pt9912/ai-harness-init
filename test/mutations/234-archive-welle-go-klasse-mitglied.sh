#!/usr/bin/env bash
# files: internal/archive/collect.go
# expect: TestKlasseVonMitgliedNenntDieWelle
# verify: test-go
#
# Nimmt der Einsammel-Regel des Unterkommandos ihre erste Klasse: ein Slice,
# dessen `Welle:`-Feld genau diese Welle nennt, gilt danach als fremd und bliebe
# liegen. Die Vorschau meldete dann eine Welle ohne ihre eigenen Slices — und
# weil der Zaehler eine Zahl ist und kein Verweis, liest das kein Gate nach.
set -euo pipefail
sed -i 's/^\t\treturn Mitglied$/\t\treturn Fremd/' internal/archive/collect.go
