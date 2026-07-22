#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_EmittierterBestandVollstaendig
#
# structureGitkeeps verliert docs/plan/adr -> das .gitkeep dieses Struktur-
# Verzeichnisses wird nicht emittiert. Der emittierte Bestand ist damit
# unvollstaendig (und im realen Emit braeche der Verzeichnis-Link auf
# docs/plan/adr/ aus AGENTS.md/harness/README.md). Kompiliert weiter.
set -euo pipefail
sed -i '/^\t\t"docs\/plan\/adr",$/d' internal/emit/templates.go
