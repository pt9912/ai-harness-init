#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandProgramNamesAProgramNotAnOperator
#
# METAZEICHEN-WORT: `namesProgram` laesst jedes Wort durch die Zeichen-Pruefung. Nach einer
# Zuweisung gilt danach ein Wort wie `|&`, `;;`, `!`, `(cmd`, `{` oder `#SECRET` als
# Programm, und der Span traegt einen Operator oder ein Kommentar-Literal im Feld `program`.
#
# ROT WIRD DIE TABELLE DES SEGMENT-WAECHTERS (und die Literal-Faelle des Wert-Waechters).
# Die Redirect-Woerter `>f` und `<<<x` faengt die Ziffern-Pruefung weiter ab und
# bleiben gruen; ihr Zahn ist Fall 408 fuer die Ziffernfolge.
set -euo pipefail
sed -i 's@^\tif strings.IndexByte(shellMetaStart, field\[0\]) >= 0 {$@\tif false {@' internal/span/span.go
