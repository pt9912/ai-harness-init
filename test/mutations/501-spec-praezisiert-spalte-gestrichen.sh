#!/usr/bin/env bash
# files: spec/spezifikation.md
# expect: jede Tabelle mit SPEC-Zeilen traegt Praezisiert als letzte Spalte und umgekehrt
# verify: test-bats
#
# STREICHT DIE SPALTE `Praezisiert` AUS DER KOPFZEILE EINER TABELLE (der Werkzeug-Tabelle):
# vier von fuenf Kopfzeilen tragen sie danach noch. Gebunden ist die Zusage, dass JEDE Tabelle
# mit SPEC-Zeilen die Spalte traegt, nicht eine Mindestzahl von Kopfzeilen. Die
# Zellen der Zeilen bleiben stehen, damit der Fall nur die Spalten-Zusage trifft und nicht
# die der leeren Zelle (Fall 502).
set -euo pipefail
sed -i 's@^\(| ID | Werkzeug-Name | erfasst zusätzlich zu Name und Status \)| Präzisiert |$@\1|@' spec/spezifikation.md
