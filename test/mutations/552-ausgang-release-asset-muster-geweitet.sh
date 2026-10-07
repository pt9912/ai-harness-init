#!/usr/bin/env bash
# files: harness/tools/full-smoke-ausgang.sh
# expect: curl-Fehler ausser (22) -> BAUM
# verify: test-bats
#
# WEITET DAS MUSTER (5) AUF JEDEN curl-FEHLER: dann ordnet der Einordner auch einen
# Fehlschlag am Ziel (curl (23), Schreibfehler) der Leitung zu. Gefuehrt ist allein der
# Exit-Code 22 (--fail, nicht mit 2xx beantwortet); der BAUM-Fall in
# test/full-smoke-ausgang.bats haelt diese Grenze.
set -euo pipefail
sed -i 's/^\t.curl: \\(22\\) The requested URL returned error: \[0-9\]+.$/\t'"'"'curl: \\([0-9]+\\)'"'"'/' harness/tools/full-smoke-ausgang.sh
