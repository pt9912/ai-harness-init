#!/usr/bin/env bash
# files: internal/emit/emit.go
# expect: TestAdaptMK_BrichtBeiFehlendemVorbindungsTarget
#
# NIMMT DER ADAPTION DIE LISTE DER VORBINDUNGS-TARGETS.
#
# Das Doc-Gate-Fragment haengt den Vorlauf-Waechter als Vorbedingung vor `doc-immutable` und
# `doc-commits`. Fuehrt das erzeugte d-check.mk eines der zwei Ziele nicht, macht die
# Vorbindungs-Zeile aus einem fehlenden Rezept einen STILLEN Erfolg: `make` meldet dann Exit 0
# und faehrt allein den Waechter, wo es ohne die Zeile mit "Keine Regel" abbraeche. Die
# Pruefung, die das beim Bootstrap laut abbrechen laesst, laeuft ueber diese Liste — leer
# heisst: kein Ziel wird mehr eingefordert (LH-QA-01, MR-017).
set -euo pipefail
sed -i 's/^var vorbindungsTargets = \[\]string{"doc-immutable", "doc-commits"}$/var vorbindungsTargets = []string{}/' internal/emit/emit.go
