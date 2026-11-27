#!/usr/bin/env bash
# files: harness/tools/dcheck-fetch.sh
# expect: fail-closed vor dem Registry-Zug: fehlende Pruefsumme
# verify: test-bats
#
# Entzaubert die fail-closed-Auflage am Pin-Zugang: `[ -n "$DCHECK_DIGEST" ]`
# wird zu `[ "" = "" ]` — der Lauf faehrt dann ohne Pruefsumme an und bricht
# spaetestens an der Pruefform-Probe statt an der fehlenden Pruefsumme. Rot
# faerbt test/dcheck-fetch.bats, Test "fail-closed vor dem Registry-Zug:
# fehlende Pruefsumme und falsche Pruefform brechen, ohne abzulegen" (seine
# Assertion hält die Meldung "fehlende Prüfsumme an gepinntem Tag" und damit
# die Stelle, die die Mutation still verschweigt). Rot gesehene Gegenprobe:
# Hand-Mutation an der realen Datei, Test 1 fiel.
set -euo pipefail
sed -i 's|\[ -n "$DCHECK_DIGEST" \]|[ "" = "" ]|' harness/tools/dcheck-fetch.sh
