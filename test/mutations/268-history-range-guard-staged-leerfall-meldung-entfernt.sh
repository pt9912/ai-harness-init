#!/usr/bin/env bash
# files: harness/tools/history-range-guard.sh
# expect: history-range-guard: --decide-staged 0 -> Meldung 'nichts zu pruefen', exit 0
#
# Ersetzt die Leerfall-Meldung aus decide_staged() durch ein No-op (`:`) --
# die einzige Zeile, die den Klassen-Fall "blind und gruen" fuer den
# --staged-Zweig traegt, faellt so aus, waehrend der `if`-Block syntaktisch
# gueltig bleibt. --decide-staged 0 faellt danach zurueck in denselben
# stummen Exit-0-Fall, den dieser Waechter beheben soll -- keine Ausgabe,
# obwohl nichts gestagt ist. Match ist die Code-Zeile mit dem `>&2`-Suffix,
# nicht die gleichlautende Zeile im BELEG-Transkript im Skriptkopf (dort
# ohne `>&2`).
set -euo pipefail
sed -i 's@echo "history-range-guard: --staged ohne gestagte Aenderung — nichts zu pruefen\.\" >&2@:@' harness/tools/history-range-guard.sh
