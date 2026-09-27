#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestSchreibe_FehlenderAblageortMeldetSichAndersAlsLeerer
# verify: test-go
#
# NIMMT DEM FEHLENDEN ABLAGEORT SEINE EIGENE LAGE: der Zweig faellt zurueck auf den
# vorhandenen, leeren Ablageort — der Leser sagt dann "existiert, gelesen wurde aber
# keine Zeile" ueber einem Ort, der es gar nicht gibt.
#
# Beide Leeren sehen ueber Aggregiere gleich aus (Zeilen == 0), und genau das ist die
# Falle: ohne den Zustand AblageortFehlt waere die Meldung dieselbe, obwohl die Lagen
# verschieden sind (slice-071 DoD (1)).
set -euo pipefail
sed -i 's@	case b.Zeilen == 0 \&\& b.AblageortFehlt:@	case false \&\& b.AblageortFehlt:@' internal/report/report.go
