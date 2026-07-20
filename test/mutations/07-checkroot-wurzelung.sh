#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_FalscheWurzelung
#
# Die Marker-Schwelle faellt auf 0: dann besteht JEDE Quelle die Wurzel-Pruefung,
# auch eine Vorfahren- oder Nachfahren-Wurzelung — der Emit schriebe in falsche
# Ziel-Pfade (Review-Befunde slice-026 F-3 und N-1).
#
# Die Vorgaenger-Fassung mutierte `case deeper == 0:` aus der zwischenzeitlichen
# Struktur-Pruefung. Nach deren Ersatz durch die Marker-Pruefung griff sie ins
# Leere — und `make mutate` hat genau das als Bedingung 2 gemeldet, statt still
# "Waechter intakt" zu behaupten.
set -euo pipefail
sed -i 's/^const minRootMarkers = 2$/const minRootMarkers = 0/' internal/emit/templates.go
