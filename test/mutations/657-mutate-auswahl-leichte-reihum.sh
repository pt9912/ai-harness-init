#!/usr/bin/env bash
# files: harness/tools/mutate-auswahl.sh
# expect: zuteilung: leichte Faelle gehen auf den Shard mit der geringsten Last
#
# Verteilt leichte Faelle reihum statt nach Last: ein Shard mit schwerem Fall bekommt
# dieselbe Zahl leichter Faelle wie ein leerer (MR-014).
set -euo pipefail
sed -i 's/if (last\[s\] < last\[best\]) best = s/if (0) best = s; best = j++ % n/' harness/tools/mutate-auswahl.sh
