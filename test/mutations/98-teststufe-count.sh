#!/usr/bin/env bash
# files: Dockerfile
# expect: dockerfile: die test-Stufe erzwingt die Test-Ausfuehrung (-count=1)
#
# Entfernt -count=1 aus der test-Stufe. Seit der Vorwaerm-Stufe (slice-057) ist der
# Kompilat-Cache ueber Builds hinweg warm — ohne -count=1 ueberspringt das Test-Werkzeug
# unveraenderte Pakete mit "(cached)". Der Lauf bliebe schnell und gruen und meldete
# gecachte Ergebnisse als bestandene Tests: eine Regression, die wie ein Erfolg aussieht.
# Vor slice-057 war die Zusage bauartbedingt sicher (kalter Cache je Build), jetzt haengt
# sie an diesem Flag — und damit an diesem Waechter.
set -euo pipefail
sed -i 's/ -count=1 / /' Dockerfile
