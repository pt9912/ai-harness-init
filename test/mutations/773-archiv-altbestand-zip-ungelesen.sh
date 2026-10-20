#!/usr/bin/env bash
# files: internal/archive/anwenden.go harness/tools/full-smoke.sh
# expect: altbestand/archiv.zip ist nicht gelesen und vollstaendig
# verify: full-smoke
#
# DIE LESEPROBE DER ERSTEN STELLE ENTFAELLT, DAS ARCHIV BLEIBT ABGESCHNITTEN: wie Fall 772
# (Zip schliesst den Writer nicht, die Probe des Traegers ist wirkungslos), und die
# Pruefung der Stufe "Archivierung im Ziel" nach dem Lauf fuer welle-smoke wird nicht
# mehr ausgewertet. Der Lauf erreicht den Altbestand-Lauf, dessen eigene Pruefung
# (archiv_gueltig ueber altbestand/archiv.zip) das abgeschnittene Archiv melden muss.
# Haelt sie nur die Existenz der Datei, bleibt der Lauf gruen.
#
# Die dritte Stelle (gefetchter Traeger aus dem gepinnten Release) ist hier nicht
# erreichbar: sie faehrt den Release-Traeger, nicht den gemutierten Baum.
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
set -euo pipefail
sed -i 's|^\tif err := pruefeArchiv(root, zipRel, imArchiv); err != nil {$|\tif err := pruefeArchiv(root, zipRel, imArchiv); false \&\& err != nil {|' internal/archive/anwenden.go
sed -i 's|^\tif err := zw.Close(); err != nil {$|\tif err := error(nil); err != nil {|' internal/archive/anwenden.go
sed -i 's|^\tif ! zip_grund=|\tif false \&\& ! zip_grund=|' harness/tools/full-smoke.sh
