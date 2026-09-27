#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestCommandWordsSplitAtTab
#
# WORTGRENZE TAB: `splitWords` trennt Woerter nicht mehr am Tab. Danach ist
# `git<TAB>commit<TAB>-m<TAB>x` EIN Wort, und die ganze Kommandozeile steht als `program` im
# Span (SPEC-031, ADR-0011: das Programm, nie die Kommandozeile); `A=b<TAB>make<TAB>gates`
# nennt nichts, weil das eine Wort ein `=` traegt.
#
# ROT WIRD DIE TABELLE DER TAB-GRENZE: jede Zeile mit Tab zwischen Woertern meldet Fall und
# Feld; `# expect:` nennt sie. Keine andere Tabelle fuehrt einen Tab zwischen Woertern.
set -euo pipefail
sed -i "s@ && c != '\\\\t'@@" internal/span/span.go
