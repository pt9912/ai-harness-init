#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestSchreibe_SammelpostenAnteilStehtDrin
#
# Streicht die Sammelposten-Zeile aus der Ausgabe. Die Rollen-Zeilen bleiben
# unveraendert — samt der Token, die ihnen die Splitting-Regel zugeteilt hat.
#
# Damit liest sich eine verteilte Summe wie eine gemessene: der Leser sieht nicht
# mehr, welcher Anteil der Bilanz auf einer Regel ruht statt auf einer Messung.
# Genau das verbietet die Pruefreihenfolge in spec/spezifikation.md §5 als Punkt 2,
# und der Emitter kann es nicht auffangen — die Zahl entsteht erst hier.
set -euo pipefail
sed -i '/Sammelposten: %d Token anteilig nach Tool-Calls/,+1d' internal/report/report.go
