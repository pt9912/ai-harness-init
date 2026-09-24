#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandProgramNamesAProgramNotAnOperator
#
# ZIFFER-REDIRECT: `namesProgram` nimmt eine Ziffernfolge vor `<`/`>` als Programm-Wort.
# Nach einer Zuweisung steht danach `2>&1` oder `12>f` als `program` im Span.
#
# ROT WIRD GENAU DIE ZIFFERN-ZEILE der Tabelle des Segment-Waechters: `>f` und `<<<x`
# beginnen mit einem Zeichen der Metazeichen-Menge und bleiben gruen (Fall 407 haelt jene
# Haelfte), ein Programm wie `7z` bleibt ebenfalls Programm.
set -euo pipefail
sed -i "s@^\treturn rest == \"\" || (rest\[0\] != '<' \&\& rest\[0\] != '>')\$@\t_ = rest\n\treturn true@" internal/span/span.go
