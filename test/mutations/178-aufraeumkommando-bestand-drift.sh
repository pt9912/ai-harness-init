#!/usr/bin/env bash
# files: internal/emit/templates/enforce/erfassung.mk
# expect: TestErfassungFragment_ZielUndNichtZusage
# verify: test-go
#
# LAESST DAS AUFRAEUM-KOMMANDO EINEN ANDEREN ORT RAEUMEN, ALS DER SCHREIBER BESCHREIBT.
#
# Die zwei Haelften koennen getrennt driften: der Schreiber HAENGT an einen Ort an, das
# Fragment RAEUMT dort. Faellt eine, ist der Ausfall STILL — `make span-clean` meldet
# weiter Erfolg, entfernt ein Verzeichnis, in dem nichts liegt, und der Bestand waechst
# unbegrenzt weiter. Genau der Fall, den die Nicht-Zusage daneben ankuendigt, nur ohne
# den Ausweg, den sie nennt. Deshalb misst der Waechter die Kopplung an span.Dir und
# nicht die Anwesenheit eines Ziels.
set -euo pipefail
sed -i 's@^SPAN_DIR ?= .harness/state/spans$@SPAN_DIR ?= .harness/spans@' internal/emit/templates/enforce/erfassung.mk
