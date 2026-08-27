#!/usr/bin/env bash
# files: harness/tools/full-smoke-ausgang.sh
# expect: 502 der Registry auf ein gepinntes Bild -> LEITUNG
# verify: test-bats
#
# NIMMT DEM EINORDNER SEINE MUSTER: die vier gemessenen Formen einer nicht mit 2xx
# beantworteten Anfrage nach einem gepinnten Artefakt verschwinden aus der Liste.
#
# DAS IST DIE ERSTE DER ZWEI BRUCHSTELLEN. Ohne Muster faellt jeder Fehlschlag in den
# BAUM-Ausgang — der Lauf bliebe rot, sagte aber ueber einen Registry-Ausfall dasselbe
# wie ueber einen Uebersetzungsfehler. Genau diese Ununterscheidbarkeit ist der Zustand,
# gegen den der Einordner steht.
#
# WARUM die bats-Stufe die schmalste ausreichende ist: der Einordner ist ein eigenes
# Skript mit einer Ausgabe, und test/full-smoke-ausgang.bats faehrt ihn ueber
# Ausschnitten echter Laeufe. Ein voller full-smoke-Lauf wuerde dieselbe Aussage
# treffen und ueber eine Minute kosten.
set -euo pipefail
sed -i "/^MUSTER=(/,/^)/{/^\t'/d}" harness/tools/full-smoke-ausgang.sh
