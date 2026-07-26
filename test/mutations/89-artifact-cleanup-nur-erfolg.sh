#!/usr/bin/env bash
# files: harness/tools/artifact-copy.sh
# expect: artifact-copy raeumt auch auf, wenn das Kopieren SCHEITERT
#
# Ersetzt den EXIT-trap durch ein NACHGESTELLTES `docker rm`. Der Unterschied ist
# genau die Haelfte der Zusage, die zaehlt: aufgeraeumt wird dann nur noch im
# ERFOLGSFALL — scheitert `docker cp`, bricht das Skript vorher ab und der
# Container bleibt liegen. Bei `release-artifacts` waeren das bis zu sechs pro Lauf.
#
# Warum als eigener Fall neben 87: Fall 87 (trap ganz weg) faerbt BEIDE
# Aufraeum-Waechter rot. Diese Mutation laesst den ersten GRUEN und trifft nur den
# zweiten — ohne sie waere der Fehlerpfad-Waechter selbst unbewacht. Genau so
# gemessen (Review-Runde-2-Befund N-1).
#
# Dollar-frei zusammengesetzt (SC2016, wie Fall 83/86/87): das Dollar-Zeichen kommt
# aus einer Variablen, damit im Muster kein `$cid` literal steht.
set -euo pipefail
d='$'
sed -i '/^trap /d' harness/tools/artifact-copy.sh
printf 'docker rm -f "%scid" >/dev/null 2>&1\n' "$d" >> harness/tools/artifact-copy.sh
