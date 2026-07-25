#!/usr/bin/env bash
# files: internal/fetch/baseline.go
# expect: TestBaseline_TagDirTraversierbar
#
# Setzt das <tag>-Verzeichnis der emittierten Baseline zurueck auf 0700 (den MkdirTemp-
# Default). Fuer den Host bleibt alles gruen — aber die Gates laufen als NICHT-Root im
# Container ueber einem read-only Mount, und ein 0700-Verzeichnis ist dort nicht
# traversierbar: das emittierte a-check bricht mit "permission denied" (Exit 2) ab,
# obwohl an der Architektur nichts falsch ist. Genau diese Klasse war real (slice-046).
set -euo pipefail
sed -i 's/os.Chmod(tmp, 0o755)/os.Chmod(tmp, 0o700)/' internal/fetch/baseline.go
