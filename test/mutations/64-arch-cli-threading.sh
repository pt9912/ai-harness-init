#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestRun_AddLangArchHexslice
#
# Kappt das Durchfaedeln des geparsten arch-Werts im add-lang-Pfad: die ERSTE
# GenerateArch-Aufrufstelle (addLang) `…, version, arch)` -> `…, version, gen.DefaultArch)`.
# add-lang emittiert dann IMMER das flache Skelett, egal was --arch sagt -> die hexSlice-
# Schicht-Dateien fehlen. Ohne den Threading-Anker liefe der Happy-Path (--arch hexslice)
# leer. Der sed ohne /g trifft nur das erste Vorkommen (addLang, VOR bootstrap); SC2016-clean.
set -euo pipefail
sed -i 's/version, arch)/version, gen.DefaultArch)/' cmd/ai-harness-init/main.go
