#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: tag-form: jedes Zeichen ausserhalb von [0-9A-Za-z.-] im Vorab- oder Build-Feld
# verify: test-bats
#
# NIMMT DER TAG-FORM IHREN ENDANKER: ein Tag, dessen Anfang der Form genuegt und dessen Rest
# nicht (`v1.0.0-rc.1` plus Zeilenumbruch und Text), geht danach durch und endet im
# Vorab-Zweig mit Exit 0. Rot faerbt der Fall, der Exit 2 fuer jeden Tag liest.
set -euo pipefail
sed -i "/^tag_form=/s|[\$]'\$|'|" harness/tools/tap-nachzug.sh
