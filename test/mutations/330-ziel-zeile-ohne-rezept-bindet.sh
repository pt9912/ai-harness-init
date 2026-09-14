#!/usr/bin/env bash
# files: internal/emit/emit.go
# expect: OHNE die Ziel-Definition GRUEN
# verify: full-smoke
#
# MACHT AUS DER ZIEL-ZEILE WIEDER EINEN NACHWEIS OHNE IHR REZEPT.
#
# Die fail-closed Bedingung des Fragments prueft die Ziel-Zeile MIT ihrer Rezept-Zeile. Der
# Operand laesst beide Ausgaenge des Probe-Werkzeugs denselben Marker tragen: eine Datei, die
# das Ziel nennt, aber kein Rezept fuehrt, waehlt dann die Bindung. `make doc-immutable` endet
# ueber so einer Datei mit Erfolg (Exit 0), der Waechter laeuft, das Modul nicht — derselbe
# stille Erfolg ueber einen anderen Ausloeser.
#
# WARUM `full-smoke` DIE SCHMALSTE AUSREICHENDE STUFE IST: die Zusage gilt dem emittierten
# Fragment in einem gebootstrappten Baum; `make test` faehrt kein Ziel-Makefile, und ein
# Go-Waechter ueber den Fragment-TEXT pruefte den Text statt die Wirkung (AGENTS.md §3.6).
# Der Preis des Modus steht im Kopf von harness/tools/mutate.sh.
set -euo pipefail
sed -i 's@? "da" : "rezeptlos"@? "da" : "da"@' internal/emit/emit.go
