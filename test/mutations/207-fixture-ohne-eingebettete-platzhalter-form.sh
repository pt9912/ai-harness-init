#!/usr/bin/env bash
# files: internal/emit/templates_test.go
# expect: courseSet() fuehrt jede Platzhalter-Pfad-Form
#
# Die Fixture verliert die EINGEBETTETE Platzhalter-Form (Platzhalter im Ziel-Text)
# und behaelt nur die spitze — genau die Lage, in der die Emit-Tests gruen bleiben,
# waehrend der reale Vorlagen-Satz eine Form fuehrt, ueber die sie nichts sagen.
#
# Die Zeilen-Adresse begrenzt den Tausch auf den courseSet()-Rumpf: dasselbe Muster
# steht in derselben Datei ein zweites Mal, als Eingabe eines Falls von
# TestNeutralizePlaceholderLinks. Mutiert wird die Fixture, und nur sie.
set -euo pipefail
sed -i '/^func courseSet(/,/^}/ s|\[<welle-NN-titel>\](\.\./<welle-NN-titel>\.md)|[welle-NN-titel](../welle-NN-titel.md)|' internal/emit/templates_test.go
