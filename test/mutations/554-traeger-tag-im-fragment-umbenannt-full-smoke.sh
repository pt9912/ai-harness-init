#!/usr/bin/env bash
# files: internal/emit/templates/enforce/traeger.mk
# expect: AUSGANG BAUM: make traeger-fetch im frischen Klon
# verify: full-smoke
#
# BENENNT DEN PIN IM EMITTIERTEN FRAGMENT UM: TRAEGER_TAGX statt TRAEGER_TAG. Im
# frischen Klon des Ziels fuehrt das Fragment dann keinen Tag, den das Transport-Skript
# liest, und make traeger-fetch bricht mit "TRAEGER_TAG ist nicht gesetzt" — sofern der
# Aufruf in harness/tools/full-smoke.sh den exportierten Dogfood-Wert NICHT erbt
# (klon_traeger_fetch, env -u). Erbt er ihn, bleibt full-smoke gruen: der Fall bindet
# die Adopter-Bedingung der Stufe (LH-QA-02, ADR-0058 Festlegung 1).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf.
# Der Lauf bricht an der Traeger-Stufe ab, lange vor dem Ende von harness/tools/full-smoke.sh.
set -euo pipefail
sed -i 's/^TRAEGER_TAG ?= /TRAEGER_TAGX ?= /' internal/emit/templates/enforce/traeger.mk
