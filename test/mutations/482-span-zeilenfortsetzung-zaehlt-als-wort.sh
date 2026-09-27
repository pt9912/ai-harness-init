#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandArgcEndsWithItsSegment
#
# ZEILENFORTSETZUNG: `splitWords` laesst einen einzelnen Backslash vor dem Zeilenende nicht
# mehr entfallen. Danach ist er ein Wort: `A=b \` + Zeilenende + `make gates` nennt `\` als
# `program`, und `make gates \` + Zeilenende + `x y` zaehlt 2 statt 3, weil das Zeilenende
# hinter dem Backslash das Segment schliesst.
#
# ROT WIRD DIE TABELLE DER ARGC-GRENZE an den zwei Zeilen mit Fortsetzung; `# expect:` nennt
# sie. Keine andere Tabelle fuehrt eine Zeilenfortsetzung.
set -euo pipefail
sed -i 's@^\t\t\tif field == lineContinuation && c == '"'"'\\n'"'"' {$@\t\t\tif false {@' internal/span/span.go
