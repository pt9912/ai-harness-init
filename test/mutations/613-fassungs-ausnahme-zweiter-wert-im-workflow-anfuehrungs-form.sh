#!/usr/bin/env bash
# files: .github/workflows/release.yml
# expect: das Formel-Skelett nennt genau die eine Ausnahme, die der Bau ins Binary injiziert
# verify: test-bats
#
# Setzt im Release-Workflow neben TRAEGER_VERSION ein GOFLAGS mit einem zweiten
# injizierten Wert in der Form `-X "name=wert"`. Der Skelett-Satz nennt weiter nur die
# Fassung als injizierten Wert (ADR-0063 Festlegung 1) — die Aussage ist ueberbreit. Die
# Mutation trifft die Workflows und die Anfuehrungs-Form des Operanden.
set -euo pipefail
sed -i 's|^\( *\)TRAEGER_VERSION: .*$|&\n\1GOFLAGS: '"'"'-ldflags=-X "main.commit=x"'"'"'|' .github/workflows/release.yml
