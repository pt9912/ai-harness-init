#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestRun_SkelCppVersionOverride
#
# skelVersion wird sprach-blind gemacht (baut immer SKEL_GO_VERSION statt SKEL_<LANG>_VERSION)
# -> SKEL_CPP_VERSION faedelt nicht mehr ins cpp-Skelett (Regression der Versions-
# Generalisierung, slice-039). Der generalisierte Versions-Knopf-Waechter muss rot werden.
set -euo pipefail
sed -i 's/strings.ToUpper(lang)/strings.ToUpper("go")/' cmd/ai-harness-init/main.go
