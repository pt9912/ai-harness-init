#!/usr/bin/env bash
# files: internal/emit/templates/enforce/commit-msg-traceability.sh
# expect: kopplung: die emittierte Kennungs-Menge ist eine Obermenge der Dogfood-Menge
# verify: test-bats
#
# DIE EMITTIERTE MENGE STREICHT EIN DOGFOOD-MUSTER: `slice-[0-9]+` entfaellt aus der
# Zeile `patterns=`; die Dogfood-Fassung fuehrt es weiter. Die Obermengen-Aussage
# emittiert ⊇ Dogfood faellt und nennt das fehlende Muster.
#
# DER PATCH SITZT AUF DER AUSFUEHRENDEN ZEILE (Zuweisung), nicht auf der Prosa im Kopf.
set -euo pipefail
sed -i "s@^\(patterns=.*MR-\[0-9\]{3}\)|slice-\[0-9\]+)@\1)@" internal/emit/templates/enforce/commit-msg-traceability.sh
