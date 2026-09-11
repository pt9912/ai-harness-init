#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning ist in modules: aktiviert
#
# Nimmt `planning` aus der `modules:`-Liste — das Modul liegt weiter im gepinnten Image, laeuft
# aber nicht mehr (LH-QA-01: 0 Befund(e), weil nichts geprueft wird). Ein Widerspruch zwischen der
# Roadmap-Sektion "## Offene Wellen" und docs/plan/planning/in-progress/ faerbt danach
# `make docs-check` nicht mehr rot.
#
# Das Muster ankert auf dem TOKEN `, planning` innerhalb der `modules:`-Zeile, nicht auf der
# vollen Liste samt Nachbarn -- ein weiteres, vor oder nach `planning` aktiviertes Modul zieht
# dem Zahn nicht die Zaehne.
set -euo pipefail
sed -i '/^modules: \[/ s/, planning\b//' .d-check.yml
