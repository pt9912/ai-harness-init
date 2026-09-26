#!/usr/bin/env bash
# files: internal/archive/refs.go
# expect: TestNachziehenInDoneErsetztJedeForm
# verify: test-go
#
# DEHNT DIE FORM-REGEL AUF DEN BAUM docs/plan/planning/done/ AUS: imReportBaum
# liefert danach auch fuer Dateien dort wahr, der Nachzug schreibt dort nur noch
# den Link. Der reine Pfad-Span dort bleibt auf dem alten Ort stehen, und
# `codepaths` faerbt an ihm `codepath-missing` (ADR-0070 Festlegung 3: die
# Gate-Begruendung traegt dort fuer den reinen Pfad-Span).
#
# WAS DAS MISST: der Fall faehrt Link, reinen Pfad-Span und Operand in einer Datei
# unter done/ und liest, dass jede der drei Formen nachgezogen ist.
#
# Der Anker steht genau einmal in refs.go, als Rumpf von imReportBaum
# (grep -cF 'return strings.HasPrefix(filepath.ToSlash(datei), reviewsDir+"/")' internal/archive/refs.go -> 1).
set -euo pipefail
sed -i 's~return strings.HasPrefix(filepath.ToSlash(datei), reviewsDir+"/")~return strings.HasPrefix(filepath.ToSlash(datei), reviewsDir+"/") || strings.HasPrefix(filepath.ToSlash(datei), doneDir+"/")~' internal/archive/refs.go
