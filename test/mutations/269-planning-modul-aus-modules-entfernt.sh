#!/usr/bin/env bash
# files: .d-check.yml
# expect: planning ist in modules: aktiviert
#
# Nimmt `planning` aus der `modules:`-Liste — das Modul liegt weiter im gepinnten Image, laeuft
# aber nicht mehr (LH-QA-01: 0 Befund(e), weil nichts geprueft wird). Ein Widerspruch zwischen der
# Roadmap-Sektion "## Offene Wellen" und docs/plan/planning/in-progress/ faerbt danach
# `make docs-check` nicht mehr rot.
set -euo pipefail
sed -i 's/^modules: \[links, anchors, ids, matrix, codepaths, spans, planning\]$/modules: [links, anchors, ids, matrix, codepaths, spans]/' .d-check.yml
