#!/usr/bin/env bash
# files: internal/emit/emit.go
# expect: TestDefaultImage_MatchesCanonical
#
# Die emittierte Tag-Referenz (emit.DefaultImage) driftet ohne die kanonische Quelle
# d-check.mk mitzuziehen; die Prosa der emittierten Kommentar-Bloecke nennt den Tag aus
# dieser Konstante. Match generisch auf den Wert (v[0-9.]*), damit der Fall bei jedem
# Pinzug greift.
set -euo pipefail
sed -i -E 's/^	DefaultImage  = "ghcr\.io\/pt9912\/d-check:v[0-9.]+"$/	DefaultImage  = "ghcr.io\/pt9912\/d-check:v0.0.1"/' internal/emit/emit.go
