#!/usr/bin/env bash
# files: internal/emit/templates/enforce/span-emit.sh
# expect: TestEnforce_WrapperSuchtDenAblageort
#
# LAESST DEN WRAPPER WOANDERS SUCHEN, als der Emitter den Traeger ablegt.
#
# Die zwei Haelften koennen getrennt driften: der Emitter LEGT das laufende Bild an
# einen Ort, der committete Wrapper SUCHT es dort. Faellt eine, ist der Ausfall STILL —
# Schweigen bei fehlendem Traeger ist die erlaubte Betriebsart des Wrappers (ADR-0022
# Festlegung 5b), also sieht ein Ziel mit falschem Suchpfad genauso aus wie eines ohne
# Traeger. Genau deshalb misst der Waechter die Kopplung und nicht das Schweigen.
set -euo pipefail
sed -i "s@bin_dir=\"\$root/.harness/state/bin\"@bin_dir=\"\$root/.harness/bin\"@" internal/emit/templates/enforce/span-emit.sh
