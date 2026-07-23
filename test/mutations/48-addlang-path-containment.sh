#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestRun_AddLangPathEscape
#
# Der <pfad>-Containment-Check wird auf einem falschen Wert berechnet (Clean(path) ->
# Clean("x")): dann greift die `..`-Erkennung nicht mehr, und `add-lang go ..` platziert
# das Skelett AUS dem Repo heraus statt mit Exit 2 abzubrechen (Review-M-1). Der
# Containment-Waechter muss rot werden.
set -euo pipefail
sed -i 's#filepath.Clean(path)#filepath.Clean("x")#' cmd/ai-harness-init/main.go
