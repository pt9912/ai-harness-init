#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandBackslashBeforeBlankIsAWord
#
# FORTSETZUNG NUR VOR DEM ZEILENENDE: `splitWords` laesst einen einzelnen Backslash vor JEDEM
# Leerraum entfallen, nicht nur vor dem Zeilenende. Danach nennt `A=b \ SECRETWORD` das Wort
# hinter dem Backslash als `program` — die Shell liest `\ ` als maskiertes Leerzeichen, das
# Wort dahinter ist kein Programm —, und `make gates \ x y` zaehlt 3 statt 4.
#
# ROT WIRD DIE TABELLE DES BACKSLASH VOR LEERZEICHEN; `# expect:` nennt sie. Die Tabelle der
# argc-Grenze fuehrt den Backslash nur vor dem Zeilenende und bleibt gruen (Fall 482 faerbt
# sie, wenn die ganze Bedingung entfaellt).
set -euo pipefail
sed -i "s@field == lineContinuation && c == '\\\\n' {@field == lineContinuation {@" internal/span/span.go
