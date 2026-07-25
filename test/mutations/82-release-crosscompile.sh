#!/usr/bin/env bash
# files: Dockerfile
# expect: die build-Stage nimmt eine Zielplattform entgegen
#
# Nimmt der build-Stage die Zielplattform-Weitergabe. Der Bau bleibt gruen und
# erzeugt weiterhin sechs Dateien mit plattform-tragenden NAMEN — nur waeren alle
# sechs dasselbe Kompilat fuer die Plattform des Build-Images. Der Name loege, das
# Artefakt schwiege. Genau davor schuetzt der Waechter.
#
# Bis Runde 1 war dies der einzige unbewachte Waechter des Slice, und ausgerechnet
# der, den die DoD namentlich nennt (Cross-Compile-Verdrahtung) — vom Verifier
# gefunden, nicht vom Sensor.
#
# Anker dollar-frei ueber Zeichenklassen statt der Variablennamen (SC2016).
set -euo pipefail
sed -i 's|GOOS=[^ ]* GOARCH=[^ ]* ||' Dockerfile
