#!/usr/bin/env bash
# files: internal/gen/gen.go
# expect: der Traeger nennt in seiner Fehlermeldung keine Sprachen oder keine Architekturen
# verify: full-smoke
#
# DIE SPRACHLISTE DER MELDUNG "unbekannte Sprache" TRAEGT DEN MARKER `verfuegbar: ` NICHT MEHR:
# das Format der Meldung bleibt, nur das Wort vor der Liste wechselt. Die Kennungs-Form-Stufe
# von full-smoke leitet die Sprachen der Kombinationen des gruenen Starts aus genau dieser
# Meldung ab; findet sie den Marker nicht, endet sie mit Exit 1, statt mit weniger oder
# festgeschriebenen Kombinationen weiterzulaufen.
#
# WARUM `full-smoke` DIE SCHMALSTE AUSREICHENDE STUFE IST: die Ableitung liest die Meldung des
# gebauten Traegers; kein Go-Test fuehrt die Stufe. Ein Nachbau der Liste in der Stufe liesse
# diesen Fall gruen. Der Preis des Modus steht im Kopf von harness/tools/mutate.sh.
set -euo pipefail
sed -i 's|; verfuegbar: %s", e.Lang,|; verfuegbar sind: %s", e.Lang,|' internal/gen/gen.go
