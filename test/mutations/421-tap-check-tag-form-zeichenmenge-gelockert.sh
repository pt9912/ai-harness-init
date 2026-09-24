#!/usr/bin/env bash
# files: harness/tools/tap-nachzug.sh
# expect: tag-form: jedes Zeichen ausserhalb von [0-9A-Za-z.-] im Vorab- oder Build-Feld
# verify: test-bats
#
# LOCKERT DIE ZEICHENMENGE DER TAG-FORM: Vorab- und Build-Feld nehmen danach jedes Zeichen
# (`.+` statt `[0-9A-Za-z.-]+`). Ein Tag wie `v1.0.0-rc$(id)` geht durch die Tag-Form und
# endet im Vorab-Zweig mit Exit 0; `v1.0.0+b;x` geht in den docker-Aufruf.
# Rot faerbt der Fall, dessen Tags die Feldform-Stufe nicht erreicht.
set -euo pipefail
sed -i '/^tag_form=/s|[[]0-9A-Za-z[.]-[]]+|.+|g' harness/tools/tap-nachzug.sh
