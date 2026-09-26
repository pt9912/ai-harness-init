#!/usr/bin/env bash
# files: harness/tools/slice-mv.sh
# expect: done: jede Form wird weiter ersetzt
# verify: test-bats
#
# DEHNT DIE FORM-REGEL AUF DEN BAUM docs/plan/planning/done/ AUS: der Zweig in
# rewrite_incoming_nach_baum, der nur den Link ersetzt, faengt danach auch die
# Dateien dort. Der reine Pfad-Span dort bleibt auf dem alten Ort stehen, und
# `codepaths` faerbt an ihm `codepath-missing` (ADR-0070 Festlegung 3: die
# Gate-Begruendung traegt dort fuer den reinen Pfad-Span).
#
# WAS DAS MISST: der Fall faehrt Link, reinen Pfad-Span, Operand, Block und
# Fliesstext in einer Datei unter done/ und liest, dass jede der fuenf Formen
# nachgezogen ist.
#
# Der Anker `docs/reviews/*)` in Spalte 4 steht genau einmal im Skript, als
# Muster des case in rewrite_incoming_nach_baum
# (grep -c '^    docs/reviews/\*)$' harness/tools/slice-mv.sh -> 1).
set -euo pipefail
sed -i 's~^    docs/reviews/\*)$~    docs/reviews/*|docs/plan/planning/done/*)~' harness/tools/slice-mv.sh
