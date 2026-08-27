#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: ein Signal berichtet, BEVOR aufgeraeumt wird
#
# Legt den Signal-Zweig wieder auf den EXIT-Zweig — der Zustand vor slice-117. Ein Ctrl-C
# loescht danach ISO_ROOT, und RUN_DIR liegt darin; der Handler KEHRT ZURUECK, bash nimmt
# den Lauf an der unterbrochenen Stelle wieder auf, und merge_report rechnet ueber ein
# geloeschtes Verzeichnis. Der Bericht meldet dann „kein einziger Worker hat ein
# Zug-Protokoll hinterlassen" unter Faellen, die ihr Urteil schon gedruckt haben.
# Das ist der Zahn zu slice-117 DoD (2): eine Ausgabe, die ihrer eigenen widerspricht.
set -euo pipefail
sed -i "s/^trap 'on_signal INT' INT\$/trap 'cleanup' INT/" harness/tools/mutate.sh
sed -i "s/^trap 'on_signal TERM' TERM\$/trap 'cleanup' TERM/" harness/tools/mutate.sh
