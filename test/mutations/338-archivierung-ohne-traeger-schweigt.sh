#!/usr/bin/env bash
# files: internal/emit/templates/enforce/archivierung.mk
# expect: ohne Traeger sagt make archive-welle nicht
# verify: full-smoke
#
# NIMMT DEM FEHLENDEN-TRAEGER-ZWEIG SEINE MELDUNG: ohne Traeger nennt das Kommando
# die Abwesenheit danach nicht mehr.
#
# Das ist der Fall des frischen Klons. Der Traeger liegt gitignored, und ein Ziel
# ohne diesen Satz liest die Abhilfe-Zeile daneben ohne ihren Anlass: dass etwas
# fehlt, steht dann nirgends.
#
# GENAU EINE ZEILE FAELLT, und das ist tragend: die Zeile mit der Abhilfe bleibt
# stehen, damit das Rezept syntaktisch heil bleibt. Eine zweite geloeschte Zeile
# naehme der letzten Rezept-Zeile ihre Fortsetzungsmarke, das Rezept braeche mit
# einem make-Fehler ab — und der Fall faerbte den Sensor rot, ohne die Zusage zu
# treffen.
#
# WARUM der Fall ueber `full-smoke` faehrt: gemessen wird die AUSGABE eines
# `make`-Aufrufs im gebootstrappten Ziel. Die Go-Stufe liest nur den Text des
# Fragments; ob das Rezept ihn erreicht, entscheidet das Rezept selbst. Dieselbe
# Ursache faellt dort an TestArchivierungFragment_TraegtPreisUndMeldung mit.
#
# Fall 186 traegt dieselbe Klasse fuer das Berichts-Fragment.
set -euo pipefail
sed -i '/^	echo "archive-welle: der Traeger liegt nicht/d' internal/emit/templates/enforce/archivierung.mk
