#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: failure_form lehnt einen unbekannten Modus AB
#
# Der Ablehnungs-Zweig faellt weg: ein unbekannter `# verify:`-Modus liefert dann
# ein LEERES Muster, und `grep -E ''` matcht jede Zeile — Bedingung 4 waere
# wirkungslos (Review-Befund slice-026 N-2). Damit bewacht make mutate endlich
# auch seinen eigenen Treiber.
#
# Der Patch zielt leerzeichen-TOLERANT auf den *)-Arm (nicht auf eine feste
# Einrueckung — die aenderte sich, als der ci-lint-Modus hinzukam und den Sensor
# beim Lauf als "Mutation hat nicht gegriffen" meldete, slice-027).
set -euo pipefail
sed -i -E 's/^([[:space:]]*)\*\)[[:space:]]+return 1 ;;$/\1*) printf "%s" "" ;;/' harness/tools/mutate.sh
