#!/usr/bin/env bash
# files: Makefile
# expect: makefile: der Go-Testlauf (docker run) erzwingt die Test-Ausfuehrung (-count=1)
#
# Entfernt -count=1 aus dem test-go-Rezept (Makefile). Der Kompilat-Cache der
# Vorwaerm-Stufe ist ueber Builds hinweg warm — ohne -count=1 ueberspringt das
# Test-Werkzeug unveraenderte Pakete mit "(cached)". Der Lauf bliebe schnell und gruen
# und meldete gecachte Ergebnisse als bestandene Tests: eine Regression, die wie ein
# Erfolg aussieht. Der Testlauf selbst ist ein `docker run` (nie gecacht) statt eines
# `RUN` im Dockerfile-Build — die Zusage haengt an -count=1 im Makefile-Rezept, und
# damit an diesem Waechter.
set -euo pipefail
sed -i '/^test-go:/,/^$/ s/ -count=1 / /' Makefile
