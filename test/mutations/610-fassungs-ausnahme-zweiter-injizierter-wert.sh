#!/usr/bin/env bash
# files: Dockerfile
# expect: das Formel-Skelett nennt genau die eine Ausnahme, die der Bau ins Binary injiziert
# verify: test-bats
#
# Haengt an den ldflags-Operanden der build-Stage einen zweiten injizierten Wert. Der Bau
# bleibt gruen, und der Kopf des Formel-Skeletts behauptet weiter, allein die Fassung
# reise im Binary — die Aussage ist ueberbreit, ohne dass sich am Skelett etwas aendert
# (ADR-0063 Festlegung 1). Die Mutation trifft die reale Quelle der Menge, nicht den Satz.
set -euo pipefail
# Anker dollar-frei ueber [$] statt dem Dollar (SC2016, dieselbe Bauart wie Fall 401).
sed -i 's|-X main.fassung=[$]{TRAEGER_VERSION}}"|-X main.fassung=${TRAEGER_VERSION} -X main.commit=x}"|' Dockerfile
