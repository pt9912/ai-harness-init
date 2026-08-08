#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestSchreibe_NennerStehtDrin
#
# Entfernt den Nenner aus der Kopfzeile der Bilanz: die Ausgabe sagt dann nicht
# mehr, dass sie ueber Subagenten-Laeufe rechnet und nicht ueber den Lauf.
#
# Der Schaden ist lautlos und genau deshalb gebunden: alle Zahlen bleiben richtig,
# nur ihr Bezug fehlt. Ein Leser nimmt die Summe fuer den Verbrauch des Laufs, und
# der Haupt-Kontext taucht in keiner Zeile auf — er traegt dauerhaft keine Zaehler
# (ADR-0012). Die Pflicht, den Nenner zu nennen, ist die positive Haelfte jener
# Entscheidung; ohne Zahn waere sie eine Absicht.
set -euo pipefail
sed -i 's@gerechnet ueber Subagenten-Laeufe, nicht ueber den Lauf@ueber den Bestand@' internal/report/report.go
