#!/usr/bin/env bash
# files: harness/tools/homebrew-formula.rb.tmpl
# expect: das Formel-Skelett nennt genau die eine Ausnahme, die der Bau ins Binary injiziert
# verify: test-bats
#
# Streicht die eine Injektion samt Anker aus dem Kopf des Formel-Skeletts. Der Satz
# behauptet dann, kein Wert reise im Binary, waehrend die build-Stage die Fassung per
# `-X` injiziert (ADR-0063 Festlegung 1).
set -euo pipefail
sed -i 's|der Bau injiziert genau einen Wert ins Binary, die Fassung (ADR-0063 Festlegung 1);|kein Wert reist im Binary;|' harness/tools/homebrew-formula.rb.tmpl
