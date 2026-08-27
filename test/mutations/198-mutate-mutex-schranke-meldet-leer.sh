#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: queue_take gibt an QUEUE_LOCK_TRIES auf, statt ewig zu warten
#
# Macht aus der Mutex-Zeitueberschreitung eine LEERE Schlange: statt Status 2 („der Lauf
# kann kein vollstaendiges Ergebnis mehr liefern") liefert queue_take danach Status 1
# („nichts mehr zu ziehen"). Der Worker haelt das fuer ein regulaeres Ende seiner
# Warteschlange, geht zur naechsten ueber und kehrt mit 0 zurueck — der Lauf verliert
# jeden Fall hinter dem Abbruch und meldet es nicht.
# Das ist der Zahn zu slice-117 DoD (3), erste Haelfte: die Schranke stand seit slice-105
# allein auf ihrem Kommentar.
set -euo pipefail
sed -i 's/^      return 2$/      return 1/' harness/tools/mutate.sh
