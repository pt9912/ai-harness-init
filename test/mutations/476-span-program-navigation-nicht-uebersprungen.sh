#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandProgramSkipsNavigationSegments
#
# NAVIGATIONS-GRENZE: `isNavigation` erkennt weder `cd` noch `set` als Navigations-Segment.
# Danach nennt `cd /x && make gates` das Feld `program` mit `cd` statt mit dem Programm, das
# nach dem Navigations-Segment laeuft (SPEC-031), und `argc` zaehlt dessen Woerter statt
# die des Programms.
#
# ROT WERDEN DIE TESTS, DIE PROGRAM ERWARTEN: die Tabelle der Navigations-Grenze meldet
# Fall und erwartetes Programm; `# expect:` nennt sie. Zusaetzlich faerbt die Mutation die
# Zeilen `cd /x && TOKEN=abc gh pr create` in `TestCommandProgramNeverEmitsValueBehindNavigation`
# rot, an der Erwartung des Programms `gh`.
set -euo pipefail
sed -i 's@^\treturn word == "cd" || word == "set"$@\treturn false@' internal/span/span.go
