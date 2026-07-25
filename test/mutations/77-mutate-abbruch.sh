#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: run_case meldet einen HOST-Treffer und BRICHT AB
#
# Macht aus dem ABBRUCH ein blosses Zurueckkehren. Der Treiber meldete den Bruch dann
# zwar noch, liefe aber weiter — bis zu 69 weitere Mutationen gegen den Host, fuer den
# es kein Backup gibt (das liegt in der Kopie). Genau der Zustand, den Runde 2 (F-4)
# beseitigt hat und der bis Runde 3 unbewacht blieb: der bats-Test prueefte nur die
# Meldung, nicht den Status.
#
# Anker: der Bereich ab der "Betroffen:"-Zeile ("Betroffen" kommt einmal vor; ein
# nacktes `exit 1` steht mehrfach in der Datei). Dollar-frei (SC2016).
set -euo pipefail
sed -i '/Betroffen: /,+2 s/^    exit 1$/    return/' harness/tools/mutate.sh
