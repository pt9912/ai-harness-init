#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: report_times FAELLT statt eine Bilanz ueber einer Teilmenge auszugeben
#
# Nimmt der Zeit-Aufschluesselung ihren Nenner: sie gibt danach auch dann eine Bilanz
# aus, wenn weniger Faelle eine Dauer tragen, als es Fall-Dateien gibt. Die Anteile
# waeren Anteile an einer Teilmenge, waehrend die Ueberschrift von der Gesamtmenge
# spricht — ein Lauf, der einen Worker verloren hat, saehe damit vollstaendig aus.
# Das ist der Zahn zu DoD (1) aus slice-105: die Aufschluesselung nennt ihren Nenner
# oder gibt es nicht.
set -euo pipefail
sed -i "s/\"\$n\" -ne \"\$total\"/\"\$n\" -gt \"\$total\"/" harness/tools/mutate.sh
