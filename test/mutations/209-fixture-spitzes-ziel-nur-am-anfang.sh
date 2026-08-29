#!/usr/bin/env bash
# files: internal/emit/templates_test.go
# expect: courseSet() fuehrt jede Platzhalter-Pfad-Form
#
# Die Fixture tauscht die Angle-Bracket-Destination `](<pfad>)` gegen ein Ziel, das
# mit `<` nur BEGINNT: `](<NNNN>-<titel>.md)`. Ein Markdown-Parser liest das nicht
# als Angle-Bracket-Destination — die Fixture fuehrt danach allein die eingebettete
# Form, waehrend der reale Satz beide fuehrt, und ueber die spitze sagen die
# Emit-Tests nichts mehr.
#
# Dieser Fall traegt die Zaehne der Klassifikation selbst: er faerbt den Waechter
# genau dann rot, wenn dieser das GANZE Ziel liest statt sein erstes Zeichen.
set -euo pipefail
sed -i '/^func courseSet(/,/^}/ s|](<pfad>)|](<NNNN>-<titel>.md)|' internal/emit/templates_test.go
