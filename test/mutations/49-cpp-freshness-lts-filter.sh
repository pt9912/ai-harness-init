#!/usr/bin/env bash
# files: harness/tools/cpp-freshness.sh
# expect: cpp-freshness: latest-lts schliesst Nicht-LTS-Interim aus
#
# Invertiert den Gerade-Jahr-LTS-Filter in extract_latest_lts (`% 2) == 0` ->
# `% 2) == 1`): dann gewinnt ein Nicht-LTS-Interim (ungerades NN.04, z. B. 25.04)
# ueber das echte LTS (24.04). Ohne den Fänger-Fixture-Test (test/cpp-freshness.bats,
# FIX_INTERIM) bliebe die LTS-Regel unbewacht — der Nachtlauf meldete Drift auf ein
# Interim (slice-042, MR-007). Match-Token `% 2) == 0` traegt kein '$' (SC2016-clean)
# und ist in extract_latest_lts eindeutig diese Zeile.
set -euo pipefail
sed -i 's/% 2) == 0/% 2) == 1/' harness/tools/cpp-freshness.sh
