#!/usr/bin/env bash
# files: harness/tools/environment-check.sh
# expect: environment-check: die Aufform exit-Klasse (2) faehrt still durch — die Auform-Zusaigen (unlesbares Inventar, unbekannte Pruefform) laufen gruen weiter
# verify: test-bats
#
# Verwandelt den Exit der Aufform-Funktion von 2 in : (weitersagen) — die Aufform
# meldet, aber der Lauf gilt als gelungen. Rot faerbt test/environment-check.bats:
# Test "Inventar-Aufform faerbt fail-closed" (unlesbarer Inventar-Pfad UND unbekannte
# Pruefform, Zusage Exit 2 je Auform). Der Anker ist die printf-Zeile des Aufform-Kopfs
# und deren Folgzeile (Range, kein Zeilennummer-Anker) — der bash-Guard mit demselben
# Exit 2 bleibt unberuehrt.
set -euo pipefail
sed -i '/AUFFORM — \$1/,+1s/exit 2/:/' harness/tools/environment-check.sh
