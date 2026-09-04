#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: jedes Unterkommando hinter $(HOST_BIN) steht im Dispatch von main()
# verify: test-bats
#
# BENENNT DEN DISPATCH-ZWEIG UM UND SCHREIBT DIE ALTE MARKE IN EINE
# KOMMENTAR-ZEILE DERSELBEN DATEI: main() fuehrt danach `archive-welle-neu`,
# waehrend der Makefile dem Traeger weiter `archive-welle` gibt. Der
# Bedien-Einstieg ist damit gebrochen — der Aufruf faellt in den Init-Pfad und
# endet an der Sperre in run() mit Exit 2, `make archive-welle` archiviert
# nichts mehr.
#
# ER TRIFFT DIE DISPATCH-SCHLEIFE, UND ZWAR DIE MENGE, GEGEN DIE SIE PRUEFT.
# Die Kalibrierung bleibt ausgeglichen: an der Zahl der Nennungen und der Zahl
# der gewonnenen Namen aendert die Mutation nichts. Rot wird der Fall, solange
# die Schleife Mitgliedschaft in der MENGE der case-Marken am Zeilenanfang
# prueft. Suchte sie die Zeichenkette `case "<name>":` irgendwo in der Datei,
# faende sie die Marke im Kommentar und bliebe gruen, waehrend der
# Bedien-Einstieg gebrochen ist. Genau diese Verwechslung ist an der Stelle
# moeglich: ueber dem switch steht ein langer Kommentarblock, der den Dispatch
# beschreibt.
#
# DIE FORM DES AUSDRUCKS: beide Ersetzungen ankern am Zeilenanfang und tragen
# den fuehrenden Tabulator des Go-Quelltexts (`\t`, GNU-sed). Die zweite haengt
# die Kommentar-Zeile VOR die getroffene Zeile, indem sie den Treffer mit `&`
# dahinter zurueckschreibt.
set -euo pipefail
sed -i 's|^\t\tcase "archive-welle":|\t\tcase "archive-welle-neu":|' cmd/ai-harness-init/main.go
sed -i 's|^\tif len(os.Args) > 1 {|\t// Beispiel: case "archive-welle": ist der Bedien-Zweig.\n&|' cmd/ai-harness-init/main.go
