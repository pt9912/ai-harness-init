#!/usr/bin/env bash
# files: harness/tools/cpp-freshness.sh
# expect: cpp-freshness: leerer Pin
#
# Aendert den Exit-Code des Leer-Pin-Zweigs von 2 (kann nicht urteilen) auf 1
# (VERALTET). Genau der Contract-Bruch, den Review-MEDIUM-1 / Verifier-DoD-3 fanden:
# `${CPP_PINNED:?}` brach mit Exit 1 ab, obwohl Header + DoD fuer den leeren Pin
# Exit 2 zusagen. Ohne den Fixture-Test (test/cpp-freshness.bats, leerer-Pin-Fall)
# bliebe diese Zusage unbewacht. Match `exit 2` ist SC2016-clean und in
# cpp-freshness.sh eindeutig dieser Zweig (slice-042, MR-007).
set -euo pipefail
sed -i 's/  exit 2/  exit 1/' harness/tools/cpp-freshness.sh
