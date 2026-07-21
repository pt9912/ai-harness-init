#!/usr/bin/env bash
# files: internal/emit/readme.go
# expect: TestRootReadme_StampStrip
#
# Der Template-Hinweis-Block wird NICHT mehr gestrippt: die emittierte Root-README
# traegt den Vorlagen-Hinweis samt externem Kurs-URL weiter — sie ist keine echte
# Repo-Datei mehr, sondern eine halb-transformierte Vorlage (LH-FA-05).
set -euo pipefail
sed -i 's/StripHintBlock(string(content))/string(content)/' internal/emit/readme.go
