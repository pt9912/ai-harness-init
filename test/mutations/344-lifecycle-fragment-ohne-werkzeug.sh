#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestSliceMvWerkzeug_LiegtAusfuehrbarUndTraegtBeideRichtungen
# verify: test-go
#
# NIMMT DAS WERKZEUG AUS DEM EMIT: das Fragment nennt danach ein Programm, das der
# Bootstrap nicht mehr ablegt.
#
# Das trifft die Zusage, die Fragment und Werkzeug zusammen halten: der
# mitemittierte Anweisungssatz schreibt den Lifecycle-Wechsel vor, und ohne das
# Werkzeug bleibt der Verweis-Nachzug Handarbeit — genau der Zustand, gegen den
# dieses Paar gebaut ist. Der Zustand ist danach leer statt benannt: die
# Anleitung zeigt auf ein Ziel, dessen Rezept in die Meldung des Interpreters
# laeuft.
#
# Fall 334 traegt dieselbe Klasse fuer das Archivierungs-Fragment (dort haengt das
# Fragment am Zweig des Traegers). Hier faellt die Datei selbst, nicht ihr Zweig.
#
# WARUM die Go-Stufe die schmalste ausreichende ist: gemessen wird der Bestand
# nach einem Emit in ein leeres Zielverzeichnis. Ein `make full-smoke`-Lauf findet
# denselben Fehler ueber die Kette des gebootstrappten Repos; sein Preis ist ein
# Docker-Bau je Sprache.
set -euo pipefail
sed -i '/^\t\tsliceMvShFile(),$/d' internal/emit/enforce.go
