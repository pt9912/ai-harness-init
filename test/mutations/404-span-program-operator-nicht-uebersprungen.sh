#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandProgramNamesAProgramNotAnOperator
#
# SEGMENT-GRENZE: `isSegmentEnd` erkennt keinen Operator mehr als Segment-Ende. Danach
# gilt in `A=b && cmd x` das Feld `&&` als Programm, und der Span traegt einen Shell-Operator
# im Feld `program` statt des Programms, das nach den Zuweisungen laeuft (SPEC-031).
#
# ROT WIRD DIE TABELLE DES SEGMENT-WAECHTERS: jede Zeile mit Operator meldet Fall und
# erwartetes Programm; `# expect:` nennt ihn, er bindet die Segment-Grenze. Zusaetzlich faerbt
# die Mutation die Zeile `TOKEN=SECRETVALUE && gh pr create` in
# `TestCommandProgramNeverEmitsAssignmentValueFragments` rot, und zwar an der Erwartung des
# Programms `gh`; ein Wert-Bruchstueck emittiert die Mutation nicht (Wert-Grenze: Fall 405).
set -euo pipefail
sed -i 's@^\treturn field == "&&" || field == ";" || field == "|" || field == "&"$@\treturn false@' internal/span/span.go
