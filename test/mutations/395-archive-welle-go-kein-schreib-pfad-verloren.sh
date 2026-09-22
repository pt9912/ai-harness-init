#!/usr/bin/env bash
# files: internal/archive/vorschau.go
# expect: TestAltbestandOhneEinenPlanTraegtKeinSchreibPfad
# verify: test-go
#
# slice-lifecycle-werkzeuge-tragen-die-kennung DoD (2): unter dem Schluessel
# AltbestandSchluessel bricht der schreibende Lauf (Anwenden) unveraendert am
# fehlenden Welle-Plan ab, weil dieser Schluessel nie einen hat. Vorschau und
# Anwenden lesen dafuer dieselbe Bedingung (EinPlanVorhanden). Diese Mutation
# nimmt sperren() den neuen Zweig weg — die Vorschau meldete wieder
# "Sperren: keine", obwohl der schreibende Lauf abbraeche.
set -euo pipefail
sed -i 's/} else if !b.EinPlanVorhanden() {/} else if false \&\& !b.EinPlanVorhanden() {/' internal/archive/vorschau.go
