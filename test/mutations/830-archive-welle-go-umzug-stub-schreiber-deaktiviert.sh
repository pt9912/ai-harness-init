#!/usr/bin/env bash
# files: internal/archive/anwenden.go
# expect: TestFundeZeileUndGeschriebeneStubMengeHaltenAmLauf
# verify: test-go
#
# DEAKTIVIERT DEN SCHREIBER DES UMZUGS-STUBS: referenzierteUmzuege kehrt immer
# leer zurueck, der schreibende Lauf schreibt keinen Umzugs-Stub an der
# Alt-Adresse. Die lesende Seite bleibt unberuehrt — UmzugsFunde laeuft weiter
# ueber den Haenger-Apparat am selben Suchraum-Differenzial, die Funde-Zeile
# meldet die Referenz weiter. Der Bericht stellt damit eine Stub-Pflicht hin,
# die der Lauf nicht schreibt: die ADR-Verweise auf die bewegten Slices loesen
# nach dem Lauf ins Leere, und der Vorher-Bericht behauptet den Stub, den der
# Baum hinterher nicht traegt (ADR-0112 Festlegungen 1 und 3).
#
# Die zweite Richtung haelt 827: deaktiviertes UmzugsFunde laesst den Stub
# stehen, den keine Funde-Zeile ankuendigt — derselbe Wächter faellt dort mit.
set -euo pipefail
sed -i 's/^func referenzierteUmzuege(root string, b Bestand, dateien \[\]string) (\[\]string, error) {$/func referenzierteUmzuege(root string, b Bestand, dateien []string) ([]string, error) {\n\treturn nil, nil/' \
	internal/archive/anwenden.go
