#!/usr/bin/env bash
# files: internal/archive/refs.go
# expect: TestNachziehenUnterReviewsSchreibtNurDieLinkForm
# verify: test-go
#
# NIMMT DEM NACHZUG UNTER docs/reviews/ SEINE FORM-REGEL: imReportBaum liefert
# danach fuer keine Datei mehr wahr, und jede Datei dort geht durch die
# Ersetzung fuer jede Form. Die Adresse im reinen Pfad-Span, im Operand, im
# Code-Block und im Fliesstext ist umgeschrieben — der Bericht nennt einen Ort,
# an dem der Vorgang nie stattfand (ADR-0070, die Politik, die die Entscheidung
# verwirft).
#
# WAS DAS MISST: der Fall faehrt EINE Datei mit den Links und den vier
# Nicht-Link-Formen zugleich. Ein Fall mit nur dem reinen Span oder nur dem Link
# bliebe bei der einen oder der anderen geschwaechten Regel gruen; dieser Fall
# faerbt bei dieser Mutation und — in 468 — bei der gegenlaeufigen.
#
# Der Anker steht genau einmal in refs.go, als Rumpf von imReportBaum
# (grep -cF 'return strings.HasPrefix(filepath.ToSlash(datei), reviewsDir+"/")' internal/archive/refs.go -> 1).
set -euo pipefail
sed -i 's~return strings.HasPrefix(filepath.ToSlash(datei), reviewsDir+"/")~return false~' internal/archive/refs.go
