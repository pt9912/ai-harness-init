#!/usr/bin/env bash
# files: internal/emit/werkzeugindex.go
# expect: TestWerkzeugIndex_ZeileJeWerkzeugTargetDisjunkt
# verify: test-go
#
# STELLT JEDES TARGET DES WERKZEUG-TEILS IN DIE GATE-TABELLE.
#
# Danach traegt ein Werkzeug-Ziel ohne Gate-Anspruch keine Marke `kein Gate` mehr und steht als
# Gate im Index (Kurs v6.16.0, modul-13-quality-gates.md §Hard Rule: genannt, aber kein Gate).
# Der Test haelt je Zeile die Bindung-Spalte.
set -euo pipefail
sed -i 's/^\t\tif gates\[n\] {$/\t\tif true || gates[n] {/' internal/emit/werkzeugindex.go
