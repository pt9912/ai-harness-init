#!/usr/bin/env bash
# files: internal/archive/anwenden.go
# expect: TestAnwendenBrichtVorDemKuerzenAb
# verify: test-go
#
# MACHT DIE RUECKLESEPROBE WIRKUNGSLOS: der Aufruf von pruefeArchiv in
# inhaltsSchritt bleibt stehen, sein Fehler wird nicht mehr ausgewertet. Ein
# abgeschnittenes, ein in einem Eintrag verfaelschtes und ein gueltiges Zip mit
# fremden Bytes laufen danach durch: die Originale werden zu Stubs gekuerzt, die
# Review-Reports geloescht, und der Volltext steht nur noch in einem Archiv, das
# niemand gelesen hat.
#
# Nichts davon wird von selbst rot: der Lauf meldet `archive-welle ok`, das Zip
# liegt an seinem Pfad, `make docs-check` bleibt gruen. Sichtbar wird der Defekt
# erst, wenn jemand dem Zeiger eines Stubs ins Archiv folgt.
set -euo pipefail
sed -i 's|^\tif err := pruefeArchiv(root, zipRel, imArchiv); err != nil {$|\tif err := pruefeArchiv(root, zipRel, imArchiv); false \&\& err != nil {|' internal/archive/anwenden.go
