#!/usr/bin/env bash
# files: harness/tools/slice-mv.sh
# expect: TestSliceMvEchtKanteOpenNachDone
# verify: test-go
#
# NIMMT main() DEN MOVE-COMMIT: der `git mv` bleibt gestaged und landet im
# Commit des Verweis-Nachzugs — Move und Inhaltsaenderung liegen in einem
# Commit (AGENTS.md §3.3), und der Lauf endet trotzdem mit 0 und dem Erfolgssatz.
#
# test/slice-mv.bats ruft main() nie. Der Go-Test faehrt main() als echten
# Prozess ueber die Kante open -> done und zaehlt die Commits und den numstat
# des vorletzten.
#
# Der Anker steht genau einmal im Skript, als Commit 1 in main()
# (grep -c '(reiner Move)"$' harness/tools/slice-mv.sh -> 1).
set -euo pipefail
sed -i '/(reiner Move)"$/d' harness/tools/slice-mv.sh
