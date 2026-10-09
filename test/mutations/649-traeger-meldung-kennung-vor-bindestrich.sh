#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestTraegerMeldungenTragenKeineKennung
# verify: test-go
#
# EINE FEHLERMELDUNG DES TRAEGERS NENNT EINE KENNUNG DIESES REPOS IN DER FORM EINES
# DATEINAMENS — `MR-077-statt-der`, die Kennung vor einem `-wort`. Der Waechter erkennt die
# Kennung, weil sie mit ihrer Ziffernfolge endet, und meldet:
#   internal/emit/enforce.go:<zeile>: MR-077
# Gegenprobe: mit `-` in der Rechts-Sperre von kennungenInText (die Kennung vor `-wort`
# verworfen) bleibt der Fall gruen — der Zahn bindet an die Rechts-Grenze (LH-QA-01).
set -euo pipefail
sed -i 's|statt konvergent zu gelten"|statt konvergent zu gelten (siehe MR-077-statt-der)"|' internal/emit/enforce.go
grep -q 'gelten (siehe MR-077-statt-der)"' internal/emit/enforce.go
