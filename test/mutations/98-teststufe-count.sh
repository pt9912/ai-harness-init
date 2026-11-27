#!/usr/bin/env bash
# files: Makefile
# expect: makefile: der Go-Testlauf am Host erzwingt die Test-Ausfuehrung (-count=1)
#
# Entfernt -count=1 aus dem Host-Testlauf-Rezept test-go (Makefile, ADR-0109:
# go test am Host; der opt-in Weg test-go-image traegt -count=1 ebenso). Der
# Kompilat-Cache ist ueber Laeufe warm — am Host wie in der Vorwaerm-Stufe des
# Images; ohne -count=1 ueberspringt das Test-Werkzeug unveraenderte Pakete mit
# "(cached)". Der Lauf bliebe schnell und gruen
# und meldete gecachte Ergebnisse als bestandene Tests: eine Regression, die wie ein
# Erfolg aussieht. Die Zusage haengt an -count=1 im Makefile-Rezept, und
# damit an diesem Waechter.
#
# Anker: /^test-go:/ erfasst das HOST-Rezept (der Range endet an der ersten
# Leerzeile und reicht nicht in test-go-image — der Image-Weg wird nicht
# beruehrt).
set -euo pipefail
sed -i '/^test-go:/,/^$/ s/ -count=1 / /' Makefile
