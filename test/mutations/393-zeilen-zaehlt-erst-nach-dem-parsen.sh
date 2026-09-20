#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestAggregiere_ZeilenZaehltAuchUnlesbare
#
# ZAEHLT b.Zeilen ERST NACH ERFOLGREICHEM PARSEN statt vorher: eine kaputte Zeile zaehlt
# dann nicht mehr zum Bestand. Genau die Unterscheidung, die Zeilen tragen soll — ein
# Bestand ohne jede Zeile gegen einen Bestand mit unlesbaren, aber vorhandenen Zeilen —,
# faellt in sich zusammen.
set -euo pipefail
sed -i '/^\t\t\tb\.Zeilen++$/d' internal/report/report.go
sed -i '/^\t\t\tverarbeite(&b, s, direkt, toolCalls, sitzungen)$/i\			b.Zeilen++' internal/report/report.go
