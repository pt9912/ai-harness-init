#!/usr/bin/env bash
# files: Makefile
# expect: das Formel-Skelett nennt genau die eine Ausnahme, die der Bau ins Binary injiziert
# verify: test-bats
#
# Reicht im build-Rezept des Makefile einen zweiten injizierten Wert in der Form
# `-X=name=wert` durch. Der Skelett-Satz nennt weiter nur die Fassung als injizierten
# Wert (ADR-0063 Festlegung 1) — die Aussage ist ueberbreit. Die Mutation trifft eine
# zweite Bau-Datei und eine zweite Operanden-Form neben Dockerfile und `-X name=`.
set -euo pipefail
sed -i 's|--target build -t ai-harness-init:build \.$|--build-arg EXTRA_LDFLAGS="-X=main.commit=x" &|' Makefile
