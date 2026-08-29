#!/usr/bin/env bash
# files: internal/emit/templates_test.go
# expect: courseSet() fuehrt jede Platzhalter-Pfad-Form
#
# Die Fixture verliert die EINGEBETTETE Platzhalter-Form (Platzhalter im Pfad) und
# behaelt nur die spitze — genau die Lage, in der die Emit-Tests gruen bleiben,
# waehrend der reale Vorlagen-Satz eine Form fuehrt, ueber die sie nichts sagen.
# Das ist der Weg, auf dem der Baum-Tausch tote Links ins Zielrepo trug.
set -euo pipefail
sed -i 's|\[<welle-NN-titel>\](\.\./<welle-NN-titel>\.md)|[welle-NN-titel](../welle-NN-titel.md)|' internal/emit/templates_test.go
