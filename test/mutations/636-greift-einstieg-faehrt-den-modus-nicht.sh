#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: greift: das Rezept von make mutate-greift faehrt mutate.sh --greift als Prozess ueber das ganze Fall-Set, MUTATE_CASES aus der Umgebung engt es nicht ein
#
# Der Einstieg `mutate.sh --greift`, den das Rezept von `make mutate-greift` faehrt, ruft
# greift_main nicht mehr und endet mit Exit 0 ohne Ausgabe. `make gates` bliebe gruen, ohne
# dass ein einziger Anker geprueft wurde; die greift-Faelle, die greift_main ueber `source`
# rufen, sehen den Einstieg nicht.
set -euo pipefail
sed -i 's/^    greift_main "[$]CASES_DIR" "[$]REPO"$/    true/' harness/tools/mutate.sh
