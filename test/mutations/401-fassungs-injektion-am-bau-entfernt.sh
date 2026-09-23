#!/usr/bin/env bash
# files: Dockerfile
# expect: die build-Stage injiziert die Fassung aus dem uebergebenen Wert
# verify: test-bats
#
# Entfernt den ldflags-Operanden aus der build-Stage. Der Bau bleibt gruen, die
# Binaries laufen — und JEDES Release-Artefakt meldet auf --version den
# Fehlt-Fall, weil kein Bau mehr injiziert. Dieselbe Klasse deckt die Variante
# "auf einen falschen Operanden gestellt" (z. B. TARGET_OS statt
# TRAEGER_VERSION): der Waechter haelt die Form des Operanden, und beide
# Aenderungen fallen an derselben Zeile auf (ADR-0063 Festlegung 1, Folgepflicht
# 2). Die Rezept-Durchreichung haelt der eigene Fall 402.
set -euo pipefail
# Anker dollar-frei ueber [$] statt dem Dollar (SC2016, dieselbe Bauart wie Fall 82).
sed -i 's|ldflags="-s -w[$]{TRAEGER_VERSION:+ -X main.fassung=[$]{TRAEGER_VERSION}}"|ldflags="-s -w"|' Dockerfile