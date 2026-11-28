#!/usr/bin/env bash
# files: Makefile
# expect: die Plattform-Liste deckt GENAU die Matrix des Lastenhefts
# verify: test-bats
#
# Streicht still eine Plattform-Zeile aus der RELEASE_PLATFORMS-Tafel (a-1,
# ADR-0115 Festlegung 6): der Matrix-Waechter in test/release-matrix.bats liest
# dieselbe Zeile am realen Bestand gegen LH-QA-04 und faellt — der Host-Release-Bau
# wuerde sonst still nur noch funf Plattformen bauen und sie als vollstaendige
# Matrix melden.
# MR-071: das Muster greift an der Tafel-Zeile, nicht an der Fassung eines
# frueheren Stands; gemessen gegen den Quell-Bestand dieses Commits.
set -euo pipefail
sed -i '/^RELEASE_PLATFORMS ?= /s/ darwin\/arm64//' Makefile
