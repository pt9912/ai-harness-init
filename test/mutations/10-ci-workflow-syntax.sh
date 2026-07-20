#!/usr/bin/env bash
# files: .github/workflows/ci.yml
# expect: syntax-check
# verify: ci-lint
#
# Der Workflow bekommt einen doppelten runs-on-Key. Faengt make ci-lint
# (actionlint) den Syntaxfehler nicht, ist das Gate zahnlos — dann waere
# ".github/workflows/ syntax-clean" eine Zusage ohne Abdeckung (slice-027, N-6).
# actionlint meldet "runs-on is duplicated ... [syntax-check]".
set -euo pipefail
printf '    runs-on: doppelt\n' >> .github/workflows/ci.yml
