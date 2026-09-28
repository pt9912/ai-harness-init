#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: form_matched findet den Treffer, auch wenn das Log VIELE passende Zeilen traegt
# verify: test-bats
#
# form_matched faellt auf die Live-Pipe zurueck (`grep -E | grep -qF`): unter
# pipefail bricht ein frueh aussteigendes `grep -qF` die Pipe mit SIGPIPE, und der
# noch schreibende `grep -E` liefert dann den Nicht-Null-Exit der Pipe, obwohl der
# Treffer real vorhanden war — trifft jedes Log mit mehr als einer zur Form
# passenden Zeile.
set -euo pipefail
sed -i "s/^  grep -qF -- \"\$expect\" <<<\"\$matched\"\$/  grep -E -- \"\$form\" \"\$out\" | grep -qF -- \"\$expect\"/" harness/tools/mutate.sh
