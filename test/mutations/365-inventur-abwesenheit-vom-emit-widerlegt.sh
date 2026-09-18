#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestTraegerInventur_KeineZelleBehauptetEineAbwesenheitDieDerEmitWiderlegt
# verify: test-go
#
# LEGT EINEN PFAD UNTER EIN PRAEFIX, AN DEM EINE ZELLE DER INVENTUR ABWESENHEIT
# BEHAUPTET: der Emit schreibt danach ein weiteres Werkzeug nach tools/harness/, waehrend
# die Freshness-Zelle weiter sagt, dort komme keiner mit.
#
# WAS DAS MISST: die eine Richtung, die DoD (3) des Slice schliesst — keine Zelle
# behauptet die Abwesenheit eines Traegers, den derselbe Lauf ablegt. Ohne diesen Fall
# waere die Zusage Text: der Emit duerfte unter dem Praefix wachsen, und die Inventur
# bliebe unangetastet falsch. Die Reibung ist gewollt — jede Erweiterung an diesem
# Praefix zwingt einen Blick auf die Inventur.
set -euo pipefail
sed -i 's@^\(\t\t{src: "templates/enforce/record-gates.sh", dst: "tools/harness/record-gates.sh", mode: 0o755, class: Konvergent},\)$@\1\n\t\t{src: "templates/enforce/record-gates.sh", dst: "tools/harness/baseline-freshness.sh", mode: 0o755, class: Konvergent},@' internal/emit/enforce.go
