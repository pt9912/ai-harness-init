#!/usr/bin/env bash
# files: internal/emit/templates/enforce/selbstpruefung.sh
# expect: emittiert: die mitgelieferte Selbstpruefung traegt eine Stufe mit ihrer Deklaration
# verify: test-bats
#
# NIMMT DER EINEN STUFE DES ZIEL-E2E IHRE DEKLARATION: die emittierte Selbstpruefung
# nennt danach keine Kurzbeschreibung mehr, und der emittierte Erzeuger bricht ueber ihr
# ab — die Sicht des Ziels haette null Zeilen statt einer.
#
# WAS DAS MISST: die Zusage "das ziel-eigene E2E traegt seine Deklaration" ist ohne
# diesen Fall Text ohne Sensor (AGENTS.md 3.6). Ein entfernter Aufruf faellt in keinem
# Gate auf — die Selbstpruefung laeuft unveraendert gruen weiter, denn sie prueft nichts
# ueber ihre eigene Deklaration, und die Sicht des Ziels steht in keinem Gate
# (LH-QA-01).
#
# WARUM DIE bats-STUFE DIE SCHMALSTE AUSREICHENDE IST: gemessen wird der TEXT der
# Vorlage, und der bats-Fall faehrt den emittierten Erzeuger ueber genau diesem Text.
# Die Stufe in harness/tools/full-smoke.sh faehrt denselben Fall im gebootstrappten
# Ziel, kostet dafuer aber einen vollen Bootstrap samt Docker-Gates.
set -euo pipefail
sed -i '/^e2e_abdeckung "—" /d' internal/emit/templates/enforce/selbstpruefung.sh
