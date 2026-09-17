#!/usr/bin/env bash
# files: internal/emit/templates/enforce/slice-mv.sh
# expect: die Funktionen der Liste KERN sind in beiden Fassungen wortgleich
# verify: test-bats
#
# NIMMT DEM EINGEHEND-SED DAS /g-FLAG — NUR IM EMITTIERTEN EXEMPLAR. Danach
# ersetzt die eine Fassung je Zeile ein Vorkommen, die andere alle; der
# Nachzug laesst in jeder Zeile mit zwei Treffern einen Verweis auf das alte
# Verzeichnis stehen.
#
# WARUM DIESER FALL DIE FALL-SAETZE NICHT BRAUCHT: jede Probe der Praefix-Faelle
# traegt genau ein Vorkommen je Zeile, und die zwei Fassungen werden getrennt
# gefahren — alle Fall-Saetze blieben mit dieser Mutation gruen. Getragen wird sie allein
# vom Kopplungs-Fall, der die Funktionsruempfe der zwei Fassungen gegeneinander
# haelt.
#
# Die zwei Fassungen sind Dogfood und Emissions-Vorlage desselben Werkzeugs. Der
# Fall trifft die EMITTIERTE: sie ist die, die ein Ziel bekommt.
#
# WARUM die bats-Stufe die schmalste ausreichende ist: der Vergleich liest zwei
# Dateien und ruft ihre Funktionen; kein git, kein Docker, kein Zielrepo.
#
# Der Anker ist `base#g`: die Zeichenfolge steht genau einmal im Skript, naemlich
# am Ende der EINGEHEND-Ersetzung (die Ausgehend-Ersetzung endet auf
# `$t)#g`). Ein laengerer Anker muesste die Shell-Variablen mitzitieren, die im
# Muster nicht expandieren.
set -euo pipefail
sed -i 's|base#g|base#|' internal/emit/templates/enforce/slice-mv.sh
