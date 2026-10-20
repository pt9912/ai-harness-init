#!/usr/bin/env bash
# files: internal/archive/anwenden.go
# expect: besteht die Leseprobe nicht
# verify: full-smoke
#
# LEGT EIN ABGESCHNITTENES ARCHIV UND NIMMT DEM TRAEGER SEINE PROBE: Zip schliesst den
# Writer nicht mehr (das Zip-Verzeichnis fehlt am Ende der Datei), und der Fehler der
# Rueckleseprobe in inhaltsSchritt wird nicht mehr ausgewertet. Der Traeger meldet
# `archive-welle ok`, Stubs stehen, das Archiv liegt an seinem Pfad — und ist nicht zu
# oeffnen.
#
# Die Stufe "Archivierung im Ziel" in harness/tools/full-smoke.sh muss das Archiv lesen
# (archiv_gueltig, `unzip -tq`) und mit der Meldung enden, dass es die Leseprobe nicht
# besteht — ueber dem Traeger aus dem Arbeitsbaum, im Aufruf `make archive-welle`.
# Ein Lauf, der nur die Existenz von archiv.zip haelt, bleibt gruen.
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's|^\tif err := pruefeArchiv(root, zipRel, imArchiv); err != nil {$|\tif err := pruefeArchiv(root, zipRel, imArchiv); false \&\& err != nil {|' internal/archive/anwenden.go
sed -i 's|^\tif err := zw.Close(); err != nil {$|\tif err := error(nil); err != nil {|' internal/archive/anwenden.go
