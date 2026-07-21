#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestGenerate_GoProfile
#
# Eine Datei faellt aus dem Go-Profil (.golangci.yml) — das generierte Skelett
# ist unvollstaendig. Der Ist-Bestand-Test (genau dieser Datei-Satz) muss rot
# werden.
set -euo pipefail
sed -i '/"\.golangci\.yml":/d' internal/gen/golang.go
