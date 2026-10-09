#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: greift: die Fall-Fassungen 29/247 aus 98bfab0b^ greifen im Bestand nicht, der Befund nennt beide
#
# Der Greift-Modus sammelt eine unveraenderte Zieldatei nicht mehr: greift_case meldet
# jeden Fall als greifend, auch wenn sein Anker im Bestand nichts trifft. `make gates`
# bliebe gruen ueber einem entwaffneten Fall — genau das, wofuer der Modus im Gate steht.
# Die Fixtures 29/247 aus 98bfab0b^ greifen real nicht und fallen damit nicht mehr auf.
set -euo pipefail
sed -i 's/^      ungegriffen="[$]ungegriffen [$]f"$/      :/' harness/tools/mutate.sh
