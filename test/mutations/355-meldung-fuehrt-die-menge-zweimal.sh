#!/usr/bin/env bash
# files: internal/emit/templates/enforce/commit-msg-traceability.sh
# expect: rot: der Grund nennt den Ort der Menge und zaehlt sie nicht selbst auf
# verify: test-bats
#
# DIE FEHLERMELDUNG FUEHRT DIE KENNUNGS-MENGE EIN ZWEITES MAL: sie zaehlt die Klassen als
# Platzhalter auf, waehrend `patterns=` sie als Muster fuehrt.
#
# Zwei Fassungen derselben Menge ohne Kopplung driften: die Aufzaehlung folgt `patterns=`
# nicht, und die Meldung nennt Klassen, die der Pruefer nicht durchsetzt. Die Meldung
# zeigt darum auf die Zeile, statt sie zu wiederholen.
#
# WARUM die bats-Stufe die schmalste ausreichende ist: gemessen wird die Ausgabe ueber
# einer Message-Datei — bash und coreutils, kein git, kein Docker, kein Zielrepo.
set -euo pipefail
sed -i 's@Erwartet wird eine Kennung aus der Menge@Erwartet wird eine Kennung aus {ADR-NNNN, LH-XX-NN, MR-NNN, slice-N}; die Menge steht@' internal/emit/templates/enforce/commit-msg-traceability.sh
