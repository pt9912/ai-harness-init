#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestBlockedSet_CoversAllGenProfiles
#
# Das go-BLOCKED-Set faellt aus blockedByLang -> blockedSet("go") liefert nur die
# universellen Paketmanager; die go-Toolchain (go/gofmt/golangci-lint/staticcheck)
# liefe im gebootstrappten Ziel ungehindert (stille Lang-Luecke). Der Waechter
# koppelt an gen.SupportedLangs(): das go-Profil == universalOnly -> rot. Kompiliert
# weiter (leere map).
set -euo pipefail
sed -i '/"go": "go gofmt golangci-lint staticcheck",/d' internal/emit/enforce.go
