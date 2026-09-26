#!/usr/bin/env bash
# files: harness/tools/slice-mv.sh
# expect: die vier Nicht-Link-Formen (Span, Operand, Block, Fliesstext) bleiben Byte fuer Byte
# verify: test-bats
#
# NIMMT DEM NACHZUG UNTER docs/reviews/ SEINE FORM-REGEL: der Zweig fuer diesen
# Baum in rewrite_incoming_nach_baum ist danach unerreichbar, und jede Datei
# dort geht durch die Ersetzung fuer jede Form. Die Adresse im reinen Pfad-Span,
# im Operand, im Code-Block und im Fliesstext ist umgeschrieben — der Bericht
# nennt einen Ort, an dem der Vorgang nie stattfand (ADR-0070, die Politik, die
# die Entscheidung verwirft).
#
# WAS DAS MISST: der Fall faehrt EINE Datei mit dem Link und den vier
# Nicht-Link-Formen zugleich. Ein Fall mit nur dem reinen Span oder nur dem Link
# bliebe bei der einen oder der anderen geschwaechten Regel gruen; dieser Fall
# faerbt bei dieser Mutation und — in 460 — bei der gegenlaeufigen.
#
# Der Anker `docs/reviews/*)` in Spalte 4 steht genau einmal im Skript, als
# Muster des case in rewrite_incoming_nach_baum
# (grep -c '^    docs/reviews/\*)$' harness/tools/slice-mv.sh -> 1).
set -euo pipefail
sed -i 's~^    docs/reviews/\*)$~    docs/reviews-aufgehoben/*)~' harness/tools/slice-mv.sh
