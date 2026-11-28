#!/usr/bin/env bash
# files: internal/emit/emit.go
# expect: TestAdaptMK_Fixture
# verify: test-go
#
# ENTHEMMT DEN HOST-CARRIER-WEG DES EMITTIERTEN d-check.mk: der Grip, der jede
# docker-Pruefzept-Form auf die Rezept-Auswahl $(DCHECK_RUN) umhaengt, ersetzt mit
# einem Suchmuster, das in der --print-mk-Ausgabe nicht liegt — die Rezepte des
# emittierten Fragments fahren direkt docker.
#
# Waechter ist TestAdaptMK_Fixture: er liest das adaptierte Fragment (Fixture der
# realen --print-mk-Ausgabe) und meldet "eine Rezept-Zeile faehrt docker direkt
# statt ueber $(DCHECK_RUN)".
set -euo pipefail
sed -i "s|body = strings.ReplaceAll(body, dockerLauf, \"\$(DCHECK_RUN)\")|body = strings.ReplaceAll(body, \"---docker-run-nicht-in-der-ausgabe---\", \"\$(DCHECK_RUN)\")|" internal/emit/emit.go
