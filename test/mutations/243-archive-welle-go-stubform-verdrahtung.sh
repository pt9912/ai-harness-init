#!/usr/bin/env bash
# files: internal/archive/anwenden.go
# expect: TestAnwendenBrichtBeiVerletzterStubFormAb
# verify: test-go
#
# TRENNT FormOK VON IHREM AUFRUFER: die Funktion laeuft weiter und urteilt
# weiter, ihr Urteil wird nur nicht mehr gelesen. Ein form-widriger Stub geht
# danach in den Baum, und der Lauf meldet `ok`.
#
# Der Fall trifft die VERDRAHTUNG, nicht die Logik — 239 nimmt FormOK ihre
# tragende Haelfte, dieser Fall die Stelle, an der der Aufrufer sie benutzt. Ein
# Test ueber der Funktion allein bleibt gruen, wenn niemand sie mehr ruft; genau
# so stand die README-Zusage "eine verletzte Stub-Form bricht zwischen den zwei
# Commits ab und nennt den Rueckweg" ohne rot gesehenes Gegenbeispiel da.
#
# Das Rot kaeme sonst nirgends her: ein Stub mit vollem Text sieht im Diff aus
# wie ein Slice, der eben nicht archiviert wurde, und das Zip daneben ist opak.
set -euo pipefail
sed -i 's/^\t\tif err := FormOK(text); err != nil {$/\t\tif err := FormOK(text); false {/' internal/archive/anwenden.go
