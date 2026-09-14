#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestArchivierungFragment_LiegtAuchOhneTraeger
# verify: test-go
#
# HAENGT DAS ARCHIVIERUNGS-FRAGMENT AN DEN ZWEIG DES TRAEGERS: scheitert dessen
# Ablage, bekommt das Ziel es nicht mehr.
#
# Das trifft den Fall, fuer den das Fragment existiert: der Traeger liegt
# gitignored, ein frischer Klon hat ihn nicht, und das Fragment ist die Stelle, an
# der das Ziel liest, dass die Archivierung nicht eingetreten ist. Hier faellt es
# mit dem Traeger, und der Zustand ist leer statt benannt.
#
# Fall 183 haengt das Erfassungs-Fragment an denselben Zweig. Zwei Fragmente,
# zwei Faelle — jedes Kommando meldet seine eigene Abwesenheit.
#
# WARUM die Go-Stufe die schmalste ausreichende ist: gemessen wird der Bestand
# nach einem Emit in ein leeres Zielverzeichnis. `make full-smoke` faende denselben
# Fehler ueber die Kette des gebootstrappten Repos und kostet dafuer einen
# Docker-Bau je Sprache.
set -euo pipefail
sed -i 's@^\t\tcontent, err := enforceContent(f.src, captured)$@\t\tif f.dst == ArchivierungMkPath \&\& !captured {\n\t\t\tcontinue\n\t\t}\n&@' internal/emit/enforce.go
