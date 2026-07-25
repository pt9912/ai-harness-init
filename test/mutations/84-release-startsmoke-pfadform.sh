#!/usr/bin/env bash
# files: harness/tools/start-smoke.sh
# expect: start-smoke nimmt die uebergebene Datei, nicht ein PATH-Kommando
#
# Nimmt die erzwungene Pfad-Form zurueck. Der Aufruf macht dann bei einem Argument ohne
# Slash einen PATH-Lookup: liegt dort ein gleichnamiges Kommando, wird DAS geprueft und
# das Skript meldet OK — waehrend die uebergebene Datei nie gestartet wurde. Ein
# Nachweis ueber dem falschen Gegenstand, und zwar ein stiller.
#
# Anker ueber Zeichenklassen statt der Variablennamen — dollar-frei (SC2016).
set -euo pipefail
sed -i '/bin="\.\/.bin"/ s|.*|	*) : ;;|' harness/tools/start-smoke.sh
