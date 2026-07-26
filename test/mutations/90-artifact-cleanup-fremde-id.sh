#!/usr/bin/env bash
# files: harness/tools/artifact-copy.sh
# expect: artifact-copy raeumt den Container auf
#
# Laesst den trap eine FREMDE Container-ID aufraeumen. Der erzeugte Container
# bliebe liegen — bei `release-artifacts` sechs pro Lauf —, waehrend das Skript
# unauffaellig mit 0 endet.
#
# Warum als eigener Fall: die Faelle 87 und 89 treffen das VORHANDENSEIN bzw. die
# Reichweite des Aufraeumens. Diese Mutation laesst beides intakt und verfaelscht
# nur das ZIEL. Vor der Verschaerfung der Assertion blieben dabei ALLE
# artifact-copy-Waechter gruen (Verifier-Befund A-1, real nachgemessen) — das ist
# die dritte und letzte Haelfte der Zusage "der Container wird immer aufgeraeumt".
#
# Dollar-frei (SC2016, wie Fall 83/86/87/89): die Zeile wird komplett ersetzt,
# das Muster selbst enthaelt kein Dollar-Zeichen.
set -euo pipefail
sed -i "/^trap /c\\trap 'docker rm -f falsche-id >/dev/null 2>&1' EXIT" harness/tools/artifact-copy.sh
