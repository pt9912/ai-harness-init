#!/usr/bin/env bash
# files: test/working-tree-hash-abnahme.bats
# expect: stamp-ausnahme: ein Pfad unter .harness/stamp/mutate bewegt den Hash nicht (ADR-0103 Festlegung 2)
# verify: test-bats
#
# Stellt den sed-Anker im Stub-`git` der Abnahme wieder her: `sed 's|^\./||'`
# ohne -z teilt nach NEWLINE, der ^-Anker trifft nur den ERSTEN NUL-Record —
# spaetere Pfade behalten "./", die Ausnahme-Klammer im realen Skript liest
# sie nicht, und der Hash bewegt den Stamp-Record mit. Rot faerbt
# test/working-tree-hash-abnahme.bats, Test 1 (a == b bricht).
set -euo pipefail
sed -i 's@{p#\./}@{p}@' test/working-tree-hash-abnahme.bats
