#!/usr/bin/env bash
# files: harness/tools/mutate-auswahl.sh
# expect: ergebnis: ein Fall der Fallmenge ohne Shard-Beleg ergibt BEFUND
#
# Ein Fall der Fallmenge ohne Beleg faerbt das Urteil nicht: waechst die Matrix ueber die
# gelesene Shard-Zahl, faellt er still aus dem Urteil (MR-014).
set -euo pipefail
sed -i '/^      echo "FEHLT    .f"$/{n;d}' harness/tools/mutate-auswahl.sh
