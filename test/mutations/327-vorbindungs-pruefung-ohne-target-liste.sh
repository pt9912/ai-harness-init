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
#
# WARUM `test-go` DIE AUSREICHENDE STUFE IST: die Adaption ist eine reine Funktion ueber der
# --print-mk-Ausgabe, der Abbruch entsteht in ihr selbst. Die emittierte Seite derselben
# Zusage (das Fragment bricht in einem Ziel ohne Rezept laut ab) traegt der Fall 329 ueber
# `make full-smoke` — dort entsteht sie erst im gebootstrappten Baum.
set -euo pipefail
sed -i 's@^func vorbindungsTargets() \[\]string { return \[\]string{"doc-immutable", "doc-commits"} }$@func vorbindungsTargets() []string { return nil }@' internal/emit/emit.go
