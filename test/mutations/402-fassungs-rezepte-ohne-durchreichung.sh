#!/usr/bin/env bash
# files: Makefile
# expect: die Bau-Rezepte reichen TRAEGER_VERSION an die build-Stage
# verify: test-bats
#
# Streicht die Durchreichung der Fassungs-Variablen aus ALLEN Bau-Rezepten. Der
# Dockerfile-Operand bliebe korrekt — aber der Wert erreichte die build-Stage
# nie, und jedes Release-Artefakt baute still ohne Fassung (ADR-0063 Festlegung
# 1, Folgepflicht 2). Der Waechter haelt jedes Rezept einzeln an die
# Durchreichung; der ldflags-Operand haelt am Bau (test/mutations/401).
set -euo pipefail
# Anker dollar-frei ueber [$] statt dem Dollar (SC2016).
sed -i 's|--build-arg TRAEGER_VERSION="[$](TRAEGER_VERSION)" ||g' Makefile