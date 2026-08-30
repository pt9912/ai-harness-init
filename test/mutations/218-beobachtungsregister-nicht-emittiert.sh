#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_EmittierterBestandVollstaendig
#
# Die Gegenrichtung der drei Faelle davor: observations.template.md wird in isRecurring
# aufgenommen und damit NICHT mehr emittiert. Das frische Repo haette dann keine
# Vergabestelle fuer BEO-<NNN> und keinen Ort fuer den Sichtungs-Schritt, obwohl die
# leere Tabelle laut Baseline-Regelwerk die ist, "mit der jedes Repo anfaengt". Der Fall
# haelt die Singleton-Entscheidung aus slice-130 fest — ohne ihn faerbt kein Sensor rot,
# wenn das Register still aus dem emittierten Bestand faellt. Kompiliert weiter.
set -euo pipefail
sed -i 's/"welle-results.template.md", "MR-NNN-titel.template.md":/"welle-results.template.md", "MR-NNN-titel.template.md", "observations.template.md":/' internal/emit/templates.go
