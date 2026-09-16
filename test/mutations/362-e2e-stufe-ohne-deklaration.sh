#!/usr/bin/env bash
# files: harness/tools/full-smoke.sh
# expect: happy path: der Erzeuger rendert je Stufe eine Zeile aus dem geprueften Skript
# verify: test-bats
#
# NIMMT EINER STUFE IHRE DEKLARATION: die dritte Stufe des Voll-E2E nennt danach keine
# Anforderung mehr, und der Erzeuger der Abdeckungs-Tabelle bricht ueber ihr ab — die
# Zeile dieser Stufe entsteht nicht.
#
# WAS DAS MISST: die Zusage "jede Stufe traegt ihre Deklaration" ist ohne diesen Fall Text
# ohne Sensor (AGENTS.md 3.6). Ein entfernter Aufruf faellt in keinem Gate auf — die Stufe
# laeuft unveraendert gruen weiter, denn sie prueft nichts ueber sich selbst, und die
# erzeugte Tabelle steht in keinem Gate (LH-QA-01: sie aendert sich mit den Deklarationen,
# nicht mit dem Zustand des Baums).
#
# WARUM DIE bats-STUFE DIE SCHMALSTE AUSREICHENDE IST: gemessen wird der TEXT des
# Skripts, und der bats-Fall faehrt den Erzeuger ueber genau diesem Text. Ein voller
# E2E-Lauf kostete einen Bootstrap samt Docker-Gates und bewiese hier nichts — er ruft den
# Erzeuger nicht, und den Laufzeit-Anker der entfernten Stufe gaebe es danach gar nicht
# mehr zu pruefen.
set -euo pipefail
sed -i '/^[[:space:]]*e2e_abdeckung "LH-FA-01 LH-FA-03 /d' harness/tools/full-smoke.sh
