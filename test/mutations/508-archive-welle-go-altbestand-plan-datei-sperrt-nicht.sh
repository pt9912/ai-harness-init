#!/usr/bin/env bash
# files: internal/archive/vorschau.go
# expect: TestArchiveWelleAltbestandSperrtImLaufBeiPlanDatei
# verify: test-go
#
# Unter dem Schluessel `altbestand` sperrt eine Datei `altbestand*.md` in done/
# den Lauf, statt ignoriert zu werden. Die Mutation macht den Zweig unerreichbar:
# der Lauf liefe mit einer Plan-Datei im Baum, die er nicht bewegt.
set -euo pipefail
sed -i 's/len(fremd) > 0 {$/false {/' internal/archive/vorschau.go
