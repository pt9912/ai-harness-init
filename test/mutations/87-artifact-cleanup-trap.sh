#!/usr/bin/env bash
# files: harness/tools/artifact-copy.sh
# expect: artifact-copy raeumt den Container auf
#
# Nimmt dem Kopier-Skript den Aufraeum-trap. Der Kopiervorgang selbst bliebe
# unauffaellig gruen — nur liesse jeder Aufruf einen gestoppten Container zurueck,
# bei `release-artifacts` also sechs pro Lauf. Die Zusage stand vor slice-051 nur
# als Kommentar im Skript (Review-Befund F-1): messbar wurde sie erst durch die
# Extraktion, gemessen wurde sie erst durch den protokollierenden docker-Stub.
#
# Anker ohne literales Dollar (SC2016, wie Fall 83/86): `^trap ` kommt im Skript
# genau einmal vor (gemessen).
set -euo pipefail
sed -i '/^trap /d' harness/tools/artifact-copy.sh
