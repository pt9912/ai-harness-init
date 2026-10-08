#!/usr/bin/env bash
# files: harness/tools/release-warten.sh
# expect: nach der Grenze Exit 0 mit der Grenz-Zeile
# verify: test-bats
#
# LAESST DAS WARTEN AN DER GRENZE SELBST URTEILEN: Exit 1 statt 0 nach der Zeile
# "GRENZE ERREICHT". Der ci-Job brache dann am Warte-Schritt statt in full-smoke, und
# die Klasse AUSGANG LEITUNG (ADR-0058 Festlegung 2) erschiene nie im Log.
set -euo pipefail
sed -i '/GRENZE ERREICHT/{n;s/exit 0/exit 1/}' harness/tools/release-warten.sh
