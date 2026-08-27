#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: ein Worker BRICHT AB, wenn sein Gruen-Vorlauf in SEINER Kopie rot ist
#
# Nimmt die Abbruch-Flagge weg. Ein Worker, dessen Sensor in SEINER Kopie schon ohne
# Mutation rot ist, haelt danach nur noch sich selbst an; die uebrigen ziehen weiter
# Faelle. Bei einem Isolations-Bruch mutieren sie dabei weiter gegen den Host-Baum,
# und ein Lauf mit ausgefallenem Worker meldet weniger, als er behauptet.
# Das ist der Zahn zu DoD (2) aus slice-105: kein Shard glaubt einer fremden Kopie
# ihr Gruen, und ein gescheiterter Vorlauf faerbt den GESAMTLAUF.
set -euo pipefail
sed -i -E 's/^([[:space:]]*)abort_run$/\1:/' harness/tools/mutate.sh
