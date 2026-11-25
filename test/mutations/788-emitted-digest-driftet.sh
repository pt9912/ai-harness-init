#!/usr/bin/env bash
# files: internal/emit/emit.go
# expect: TestDefaultDigest_MatchesCanonical
#
# Der emittierte Pull-Digest (emit.DefaultDigest) driftet ohne die kanonische Quelle
# d-check.mk mitzuziehen: der Bootstrap schrieb ein Fragment, dessen docker-Lauf ein
# anderes Image zieht, als `make docs-check` hier faehrt. Match generisch auf den Wert
# ([0-9a-f]{64}), damit der Fall bei jedem Pinzug greift.
set -euo pipefail
sed -i -E 's/^	DefaultDigest = "sha256:[0-9a-f]{64}"$/	DefaultDigest = "sha256:0000000000000000000000000000000000000000000000000000000000000000"/' internal/emit/emit.go
