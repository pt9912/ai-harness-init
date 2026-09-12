#!/usr/bin/env bash
# files: harness/tools/slice-mv.sh
# expect: TestSliceMvEchtUebergehtAcceptedADRBeimNachzug
# verify: test-go
#
# main() liest eingehend_ausgenommene_pfade() weiterhin in in_pathspec[] ein,
# uebergibt das Array aber nicht mehr an den `git grep`-Aufruf — die Liste
# bleibt unveraendert richtig, main() BENUTZT sie nur nicht mehr. Der
# EINGEHEND-Nachzug durchsucht damit den ganzen Repo-Baum inklusive
# docs/plan/adr, und eine Accepted-ADR bekaeme ihren Verweis nachgezogen
# (ADR-0042 Festlegung 2 gebrochen).
#
# test/slice-mv.bats sieht das nicht: sein Fall
# "eingehend_ausgenommene_pfade: ..." ruft nur die Funktion selbst auf, nie
# main(). Der Anker ist die Zeile, die "${in_pathspec[@]}" unmittelbar vor
# "2>/dev/null" traegt — eindeutig
# (grep -c 'in_pathspec\[@\]}" 2>/dev/null' harness/tools/slice-mv.sh -> 1).
set -euo pipefail
sed -i -E 's/-- "\$\{in_pathspec\[@\]\}" 2>\/dev\/null/-- "." 2>\/dev\/null/' harness/tools/slice-mv.sh
