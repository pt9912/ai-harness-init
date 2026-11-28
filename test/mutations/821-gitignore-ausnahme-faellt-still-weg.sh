#!/usr/bin/env bash
# files: .gitignore
# expect: gitignore: die committete Key-Klasse und der E2E-Stempel sind nicht ignoriert
# verify: test-bats
#
# DIE GITIGNORE-AUSNAHME DER JE-CHECK-KEYS FAEHRT STILL WEG (ADR-0111 Festlegung
# 1): die Negation `!.harness/state/gates-passed-*.key` entfaellt, die Klasse
# `/.harness/state/*` ignoriert sie wieder — der Klon transportiert die Keys
# nicht mehr, der push-main-Job faehrt fail-closed voll, und die committete
# Klasse verlautet nichts.
#
# Waechter ist der check-ignore-Fall in test/ci-stempel-committed.bats
# ("gitignore: die committete Key-Klasse und der E2E-Stempel sind nicht
# ignoriert"): er misst die reale .gitignore und faellt, sobald die Klasse
# wieder in den Ignorier-Bereich faellt.
set -euo pipefail
sed -i '/^!\.harness\/state\/gates-passed-\*\.key$/d' .gitignore
