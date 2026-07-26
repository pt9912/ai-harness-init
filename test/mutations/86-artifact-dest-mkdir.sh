#!/usr/bin/env bash
# files: harness/tools/artifact-copy.sh
# expect: artifact-copy legt ein FEHLENDES Zielverzeichnis an
#
# Nimmt dem Kopier-Skript das Anlegen des Zielverzeichnisses — also genau den
# Defekt zurueck, den slice-051 behoben hat. Ohne diesen Fall waere der Waechter
# selbst unbewacht: er koennte spaeter zahnlos werden (etwa wenn `mkdir -p` in
# einen Zweig rutscht, der nicht immer laeuft), ohne dass es jemand bemerkt.
#
# Die Klasse ist real eingetreten, nicht konstruiert: ein NUTZER meldete, dass
# `make artifact DEST=./bin` mit "invalid output path: directory … does not
# exist" abbricht — genau der Aufruf, den README und Benutzerhandbuch vorschreiben.
# Kein Sensor fand es, weil die CI den Defekt an der Aufrufstelle umging
# (`mkdir -p dist` vor dem make-Aufruf); sie war gruen, WEIL sie kompensierte.
#
# Anker ohne literales Dollar (SC2016, wie Fall 83): die Zeile wird ueber ihren
# Anfang adressiert — im Skript gibt es genau ein `mkdir -p` (gemessen), das
# Muster bleibt damit dollar-frei und braucht keine Inline-Suppression
# (Hard Rule 3.2 verbietet die).
set -euo pipefail
sed -i '/^mkdir -p /d' harness/tools/artifact-copy.sh
