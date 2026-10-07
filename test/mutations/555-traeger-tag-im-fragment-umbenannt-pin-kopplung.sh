#!/usr/bin/env bash
# files: internal/emit/templates/enforce/traeger.mk
# expect: pin-kopplung
# verify: test-bats
#
# BENENNT DEN PIN IM EMITTIERTEN FRAGMENT UM: TRAEGER_TAGX statt TRAEGER_TAG, Wert
# unveraendert. pin_wert in test/traeger-fetch.bats liest genau `^<name> ?=`; liest es
# per Praefix, liefert die umbenannte Zeile denselben Wert, und der Fall pin-kopplung
# bleibt gruen (LH-QA-01).
set -euo pipefail
sed -i 's/^TRAEGER_TAG ?= /TRAEGER_TAGX ?= /' internal/emit/templates/enforce/traeger.mk
