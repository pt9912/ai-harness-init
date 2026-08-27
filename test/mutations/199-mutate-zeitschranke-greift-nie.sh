#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: ein Lauf ohne Fortschritt endet an der Zeitschranke
#
# Nimmt der Zeitschranke ihre Messung: die verstrichene Stille rechnet sich danach immer
# zu null, und keine Schranke wird je erreicht. Ein Worker, der nicht zurueckkommt, laesst
# den Lauf damit wieder unbegrenzt warten — lokal beendet ihn niemand, und ein haengender
# Sensor ist von einem langsamen nicht mehr zu unterscheiden.
# Getroffen ist die Groesse, nicht der Schwellenwert: eine Schranke, die ueber einer
# konstanten Null steht, ist keine, gleich wie niedrig sie gesetzt wird.
# Das ist der Zahn zu slice-117 DoD (1) und (3), zweite Haelfte.
set -euo pipefail
sed -i 's/SECONDS - marke/0 * (SECONDS - marke)/' harness/tools/mutate.sh
