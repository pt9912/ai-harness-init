#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandArgcEndsWithItsSegment
#
# ARGC-GRENZE: `segmentArgc` sucht das Segment-Ende an keinem Operator-Feld mehr. Danach
# zaehlt `argc` fuer `make gates && echo x` die Woerter bis zum Zeilenende (4) statt die
# des Segments (1), fuer jede Zeile mit Operator hinter dem Programm (SPEC-021).
#
# ROT WIRD DIE TABELLE DER ARGC-GRENZE: jede Zeile mit Operator meldet Fall und erwartetes
# argc; `# expect:` nennt sie. Das Feld auf `;` und das Zeilenende als Segment-Ende stehen in
# `closesSegment` und sind von dieser Mutation nicht getroffen (Faelle 480 und 481).
set -euo pipefail
sed -i 's@^\t\tif isSegmentEnd(f) || f == "||" {$@\t\tif false {@' internal/span/span.go
