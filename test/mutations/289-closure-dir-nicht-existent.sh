#!/usr/bin/env bash
# files: .d-check.yml
# expect: der konfigurierte closure.dir existiert als Verzeichnis
#
# Setzt `dir` unter `closure:` auf einen Pfad, der im Repo nicht existiert
# (`docs/plan/planning/does-not-exist-289`) — der Aktivierungs-Schalter bleibt nicht-leer, die
# Existenz-Bedingung faellt. `docs-check` selbst faende in einem solchen Verzeichnis keine
# Kandidaten und liefe fail-open ins Leere statt die Config als kaputt zu melden; dieser Waechter
# haelt die Existenz-Kopplung ohne einen Docker-Lauf.
set -euo pipefail
sed -i 's#^    dir: docs/plan/planning/done$#    dir: docs/plan/planning/does-not-exist-289#' .d-check.yml
