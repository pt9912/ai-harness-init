#!/usr/bin/env bash
# files: Makefile
# expect: rezept: lint ruft das PATH-Binary ohne Ablage-Fallback
# verify: test-bats
#
# Legt einen Ablage-Fallback ins lint-Rezept zurück: der Aufruf griffe dann auf
# .harness/state/bin/golangci-lint zurück, auch wenn environment-check den
# Umgebungs-Befund ("PATH trägt das Werkzeug nicht") gemeldet hat — zwei Wege
# mit widersprüchlichen Urteilen, und die Kante müsste den Befund nicht tragen.
# Die Besorgung trägt die Umgebung, der Check belegt sie (Baseline-Regelwerk
# modul-14 §Der zweite Träger; Beschluss 2026-11-27: golangci-lint-fetch entfällt,
# die Ablage hat keine Träger-Rolle). Rot faerbt test/rezept-host.bats.
set -euo pipefail
sed -i "s@^\tgolangci-lint run \./\.\.\.@\tbin=\"\\\$\\\$(command -v golangci-lint)\"; [ -n \"\\\$\$bin\" ] || bin=.harness/state/bin/golangci-lint; \"\\\$\$bin\" run ./...@" Makefile
