#!/usr/bin/env bash
# files: harness/tools/full-smoke-ausgang.sh
# expect: Uebersetzungsfehler im Baum -> BAUM
# verify: test-bats
#
# MACHT DEN LEITUNGS-AUSGANG BEDINGUNGSLOS: der Einordner meldet ihn auch dann, wenn
# keine seiner Formen in den gelesenen Zeilen steht.
#
# DAS IST DIE ZWEITE DER ZWEI BRUCHSTELLEN, und die gefaehrlichere. Ein Einordner, der
# immer LEITUNG sagt, besteht jede Pruefung der ersten Richtung und erklaert dabei
# jeden Uebersetzungsfehler zur Umgebungsfrage. Eine Begruendung, die auf ihren eigenen
# Treffer nicht zutrifft, ist schlechter als keine: sie beruhigt.
#
# WARUM die bats-Stufe die schmalste ausreichende ist: gemessen wird die Richtung
# BAUM in test/full-smoke-ausgang.bats, ueber dem Ausschnitt eines echten
# Uebersetzungsfehlers.
set -euo pipefail
sed -i 's@^treffer=""@treffer="0|dieser Beleg stammt aus keiner gelesenen Zeile"@' harness/tools/full-smoke-ausgang.sh
