#!/usr/bin/env bash
# files: cmd/ai-harness-init/archive_welle.go
# expect: TestArchiveWelleVorschauSchreibtNichtsObwohlDerLaufLiefe
# verify: test-go
#
# NIMMT DEM VORSCHAU-SCHALTER SEINE WIRKUNG: die Bedingung wird konstant falsch,
# der Zweig faellt danach in archive.Anwenden durch — mit `--vorschau`
# archiviert der Lauf.
#
# Das ist die einzige Eigenschaft, die einen BLICK auf eine Welle von ihrer
# Archivierung trennt: der Traeger schreibt in den versionierten Baum und
# loescht darin. Ein Aufrufer, der die Vorschau gewohnheitsmaessig fuer
# gefahrlos haelt, bekaeme zwei Commits und geloeschte Review-Reports.
#
# Von selbst wird das nicht rot. Der Guard steht HINTER der Sperren-Pruefung, und
# an einem Baum mit Sperre endet der Lauf schon dort — ein Test ueber einem
# solchen Baum bliebe unter dieser Mutation gruen, egal wie sein Name lautet.
# Rot wird sie nur an einem SPERRENFREIEN Baum, und genau den stellt der
# erwartete Fall her.
set -euo pipefail
sed -i 's/^\tif vorschau {$/\tif false {/' cmd/ai-harness-init/archive_welle.go
