#!/usr/bin/env bash
# files: internal/emit/archgate.go
# expect: TestArchGateMk_WaechterKeytNichtAufNutzerVariable
#
# Setzt den include-once-Waechter zurueck auf die Variable, die das emittierte a-check.mk
# als ADOPTER-OVERRIDE anbietet. make importiert die Umgebung: wer den Override benutzt,
# verliert dann den include, und im Root-Fragment zeigt GATE_CHECKS auf ein undefiniertes
# Target — der dokumentierte Knopf schaltet das Gate ab. Genau diese Klasse fanden Review
# (F-1) und Verifikation (R-1) unabhaengig voneinander.
set -euo pipefail
sed -i 's/archIncludeSentinel = "ARCH_GATE_MK_INCLUDED"/archIncludeSentinel = "A_CHECK_IMAGE"/' internal/emit/archgate.go
