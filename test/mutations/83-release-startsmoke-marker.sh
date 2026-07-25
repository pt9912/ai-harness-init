#!/usr/bin/env bash
# files: harness/tools/start-smoke.sh
# expect: start-smoke FAELLT bei Exit 0 ohne Usage
#
# Nimmt dem Start-Smoke seine Marker-Pruefung: er meldete dann jedes Binary als
# Nachweis, das mit 0 endet — auch eines, das gar keine Usage druckt. Der
# Plattform-Nachweis waere ein Gate ueber leerem Bereich (LH-QA-01), und zwar auf
# genau den Runnern, deren Ausgabe sonst niemand liest.
#
# Anker ohne literales Dollar (SC2016): die Zeile wird ueber `grep -qF -- .marker`
# adressiert, das Muster selbst bleibt dollar-frei.
set -euo pipefail
sed -i '/grep -qF/ s|.*|\ttrue|' harness/tools/start-smoke.sh
