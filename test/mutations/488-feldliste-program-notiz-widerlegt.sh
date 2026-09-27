#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestFeldliste_ProgramNotizWidersprichtSpecNichtMehr
#
# PROGRAM-NOTIZ AUF DIE WIDERLEGTE FASSUNG ZURUECKGESETZT: die Notiz zum Feld `program`
# behauptet wieder "das erste Token der Kommandozeile, nie die Zeile" — seit
# slice-204-das-programm-feld-nennt-das-programm nachweislich falsch (`cd /x && make gates`
# liefert program="make"; die geltende Regel steht in spec/spezifikation.md, Zeile SPEC-021:
# das erste Wort des AUSGEFUEHRTEN SEGMENTS, nie der ganzen Kommandozeile).
#
# ROT WIRD TestFeldliste_ProgramNotizWidersprichtSpecNichtMehr und nur er; die uebrigen
# Feldliste-Waechter pruefen Menge und Form der Notizen, nicht den Wortlaut dieser einen.
set -euo pipefail
sed -i 's@Welches Programm lief? — das erste Wort des ausgeführten Segments, nie das der ganzen Kommandozeile@Welches Programm lief? — das erste Token der Kommandozeile, nie die Zeile@' internal/span/fieldlist.go
