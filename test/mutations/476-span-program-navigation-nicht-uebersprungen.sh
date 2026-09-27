#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandProgramSkipsNavigationSegments
#
# NAVIGATIONS-GRENZE: `isNavigation` erkennt weder `cd` noch `set` als Navigations-Segment.
# Danach nennt `cd /x && make gates` das Feld `program` mit `cd` statt mit dem Programm, das
# nach dem Navigations-Segment laeuft (SPEC-031), und `argc` zaehlt dessen Woerter statt
# die des Programms; `cd /x && TOKEN=abc gh pr create` nennt `cd` statt `gh`.
#
# ROT WIRD DIE TABELLE DER NAVIGATIONS-GRENZE, und nur sie: sie traegt die Zeilen mit
# erwartetem Programm, die schlichten Woerter und die Zeilen mit Wert hinter dem Segment.
# `# expect:` nennt sie. Die Tests der unschlichten Woerter und der mehrzeiligen Zeilen
# erwarten `cd` und bleiben gruen; die argc-Tabelle fuehrt kein Navigations-Segment.
set -euo pipefail
sed -i 's@^\treturn word == "cd" || word == "set"$@\treturn false@' internal/span/span.go
