#!/usr/bin/env bash
# files: internal/emit/templates/enforce/traeger.mk
# expect: AUSGANG LEITUNG: make traeger-fetch im frischen Klon
# verify: full-smoke
#
# STELLT DIE LAGE AM TAG-COMMIT AN DER REALEN QUELLE HER: der emittierte TRAEGER_TAG
# zeigt auf einen Tag ohne veroeffentlichtes Release. make traeger-fetch im frischen
# Klon des Ziels bekommt von curl dieselbe Antwort wie in den gemessenen CI-Jobs
# (curl: (22) ... 404), und full-smoke ordnet sie ueber das Muster (5) von
# harness/tools/full-smoke-ausgang.sh der Leitung zu (LH-QA-01, ADR-0058).
#
# WAS DIESER FALL MISST, UND 551/552 NICHT: dass der Fehltext des Abrufs den
# Einordner im Lauf unveraendert erreicht. Die Klasse steht in der Beleg-Zeile darunter;
# der Treiber haelt allein die FEHLER-Zeile.
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf, und laeuft fast voll durch: die Stufe liegt
# spaet in harness/tools/full-smoke.sh.
set -euo pipefail
sed -i 's/^TRAEGER_TAG ?= .*$/TRAEGER_TAG ?= v9.99.9-gibt-es-diesen-tag-nicht/' internal/emit/templates/enforce/traeger.mk
