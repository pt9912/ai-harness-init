#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestAggregiere_SummiertJeRolle
#
# Laesst die Output-Token aus der Summe fallen: gezaehlt wird nur noch, was in
# den Lauf hineinging.
#
# Die Bilanz bliebe plausibel — alle Rollen-Zeilen stehen, alle Prozentsaetze
# addieren sich auf hundert —, waere aber die falsche Groesse. Modul 15
# §Token-Attributions-Regeln verlangt "Input- UND Output-Token pro agent.role";
# eine Bilanz, die nur die halbe Achse summiert, verschiebt zudem das Verhaeltnis
# zwischen den Rollen, weil sie verschieden viel schreiben.
set -euo pipefail
sed -i 's@^\t\ttokens += \*s.OutputTokens$@\t\ttokens += 0@' internal/report/report.go
