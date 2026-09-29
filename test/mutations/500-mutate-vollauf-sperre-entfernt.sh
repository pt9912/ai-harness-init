#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: ohne MUTATE_CASES bricht der Lauf ab, bevor kopiert wird
# verify: test-bats
#
# NIMMT DIE VOLLAUF-SPERRE: main() faehrt danach ohne MUTATE_CASES und ohne
# MUTATE_FORCE als normaler Vollauf durch — der Waechter
# "driver: ohne MUTATE_CASES bricht der Lauf ab, bevor kopiert wird" faerbt rot,
# weil die Sperren-Meldung fehlt und der Lauf mit Exit 0 endet. Die REIHENFOLGE
# gegen den Beleg-Uebersprung haelt ein zweiter Waechter:
# "driver: ein gueltiger Beleg entlastet den Aufruf vor der Vollauf-Sperre".
sed -i '/^  if \[ -z "[$]{MUTATE_CASES+x}" \] && \[ -z "[$]{MUTATE_FORCE:-}" \]; then$/,/^  fi$/d' harness/tools/mutate.sh
