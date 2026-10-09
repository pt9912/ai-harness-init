#!/usr/bin/env bash
# files: harness/tools/mutate-auswahl.sh
# expect: ergebnis: ein Shard mit Exit ungleich 0 ergibt BEFUND, auch wenn seine Faelle ok sind
#
# Das Urteil uebergeht den Exit eines Shards: ein abgebrochener make-Lauf mit ok-Zeilen
# ergibt gruen (MR-014).
set -euo pipefail
sed -i '/^      \[ ".rc" = 0 \] || befund=1$/d' harness/tools/mutate-auswahl.sh
