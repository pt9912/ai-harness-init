#!/usr/bin/env bash
# files: harness/tools/mutate-auswahl.sh
# expect: zuteilung: schwere Faelle liegen auf verschiedenen Shards
#
# Legt jeden schweren Fall auf Shard 0: die serielle Spur eines Shards traegt dann alle
# full-smoke-Faelle, und die Wanduhr richtet sich nach ihm (MR-014).
set -euo pipefail
sed -i 's/\(.1 == 1 { s = \)k % n\(; k++;\)/\10\2/' harness/tools/mutate-auswahl.sh
