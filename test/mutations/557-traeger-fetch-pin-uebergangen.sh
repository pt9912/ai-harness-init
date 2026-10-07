#!/usr/bin/env bash
# files: internal/emit/templates/enforce/traeger-fetch.sh
# expect: der verdrehte sha256-Pin endete mit 0
# verify: full-smoke
#
# UEBERGEHT DEN PIN IM EMITTIERTEN TRANSPORT-SKRIPT: der erwartete Digest beginnt leer
# statt mit dem Pin der Plattform, und das Skript faellt immer in den Manifest-Kanal.
# Fall (c) der Stufe "make traeger-fetch im frischen Klon" in harness/tools/full-smoke.sh
# setzt allein den Pin der Host-Plattform, verdreht; uebergangen, verifiziert der Fetch
# gegen die SHA256SUMS des Release, endet mit 0, und (c) wird rot. Der Fall bindet den
# Vorrang des Pins vor dem Manifest (LH-QA-02, ADR-0059 Festlegung 3).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf. DAUER: 27.31 s fuer diesen Fall gegen 148.31 s
# fuer den gruenen Vorlauf (make mutate, Zeilen "Zeit je Fall" und "Gruen-Vorlaeufe") —
# der Lauf bricht an der Traeger-Stufe ab, lange vor dem Ende von harness/tools/full-smoke.sh.
set -euo pipefail
sed -i 's|^erwartet="\$TRAEGER_SHA256"$|erwartet=""|' internal/emit/templates/enforce/traeger-fetch.sh
