#!/usr/bin/env bash
# files: internal/emit/templates/enforce/erfassung.mk
# expect: ohne Traeger sagt make span-report nicht, was fehlt und was das NICHT heisst
# verify: full-smoke
#
# NIMMT DEM FEHLT-ZWEIG SEINEN TRAGENDEN SATZ: `make span-report` meldet ohne Traeger
# noch, dass er fehlt — aber nicht mehr, dass das KEINE Aussage ueber den Bestand ist.
#
# DAS IST DIE VIERTE MELDUNGS-LAGE, und sie liegt vor den drei Lagen des Lesers: ein
# frischer Klon hat den gitignorierten Traeger nicht. Ohne diesen Satz liest ein Adopter
# die Stille als Aussage ueber SEINEN BESTAND — er haelt ein Repo ohne Leser fuer ein
# Repo ohne Erfassung und sucht den Fehler in seinen Laeufen. Es ist dieselbe
# Verwechslung, gegen die der Leser eine Ebene tiefer den leeren vom zaehlerlosen
# Bestand trennt, nur eine Ebene hoeher.
#
# WARUM `full-smoke` DIE SCHMALSTE AUSREICHENDE STUFE IST: der Zweig ist eine
# Shell-Schleife IM MAKEFILE-REZEPT. Kein Go-Test faehrt `make`, und kein Go-Waechter
# behauptet diese drei Saetze — behauptete einer sie, waere er die schmalere Stufe und
# dieser Fall gehoerte dorthin. Der Preis des Modus steht im Kopf von
# harness/tools/mutate.sh.
set -euo pipefail
sed -i '/echo "span-report: das ist KEINE Aussage ueber den Bestand, sondern ueber den Leser."; \\$/d' internal/emit/templates/enforce/erfassung.mk
