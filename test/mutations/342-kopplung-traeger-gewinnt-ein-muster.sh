#!/usr/bin/env bash
# files: harness/tools/commit-msg-traceability.sh
# expect: kopplung: Traeger und Config tragen dieselbe Muster-Menge
# verify: test-bats
#
# NIMMT DEM TRAEGER EIN MUSTER DAZU: die ausfuehrende Zeile fuehrt danach
# zusaetzlich `BEO-[A-Z]+`, das die Gate-Config nicht kennt. Der Traeger nimmt
# damit Commits an, die das Gate zurueckweist — die Fassungen weichen in der
# anderen Richtung auseinander als im Fall daneben.
#
# WARUM DIE AUSFUEHRENDE ZEILE UND NICHT DIE PROSA: der Patch sitzt auf der
# Zuweisung; die Kopf-Kommentare nennen die Kennungs-Klassen nur. Ein Zahn auf
# den Wortlaut waere aus der Prosa erfuellbar und damit blind.
#
# WARUM die bats-Stufe die schmalste ausreichende ist: gemessen werden zwei
# Textfassungen gegeneinander — kein Docker, kein d-check-Image.
set -euo pipefail
sed -i 's@slice-\[0-9\]+)@slice-[0-9]+|BEO-[A-Z]+)@' harness/tools/commit-msg-traceability.sh
