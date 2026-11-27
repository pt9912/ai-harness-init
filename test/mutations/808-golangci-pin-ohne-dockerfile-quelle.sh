#!/usr/bin/env bash
# files: .d-check.yml
# expect: pinsync: das Pin golangci-lint paart die Inventar-Soll-Zeile abgeleitet gegen die GOLANGCI_LINT_VERSION-Stellen
# verify: test-bats
#
# Entfernt die Dockerfile-Quelle aus dem Pin golangci-lint: der Pin-Stand der
# lint-Stage (ARG GOLANGCI_LINT_VERSION) wäre vom Stellen-Abgleich entkoppelt —
# ein Bump nur dort staende ungehaelt gegen Inventar und Pin. Rot faerbt der
# Config-Waechter test/pinsync-modul-wiring.bats; ein verfaelschter VALUE an GENAU
# EINER Quelle faerbt `make docs-check` mit dem Grund-Code `pinsync-mismatch`
# rot (Beleg-Typ: harness/sensors/docs-check.md §Grenze, Modul pinsync).
set -euo pipefail
sed -i '/{file: Dockerfile, pattern:/d' .d-check.yml
