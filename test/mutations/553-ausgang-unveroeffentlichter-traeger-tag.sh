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
# DIE ZUWEISUNG BLEIBT "?=", wie im Fragment: das Dogfood-Makefile exportiert
# TRAEGER_TAG, aber der Aufruf im Klon (klon_traeger_fetch in
# harness/tools/full-smoke.sh) laeuft ohne ihn — env -u TRAEGER_TAG, MAKEFLAGS
# entfernt. Der Tag des Laufs ist damit der des emittierten Fragments, und ein
# verdrehter Wert hinter "?=" erreicht den Abruf.
#
# WAS DIESER FALL MISST, UND 551/552 NICHT: dass der Fehltext des Abrufs den
# Einordner im Lauf unveraendert erreicht. Die Klasse steht in der Beleg-Zeile darunter;
# der Treiber haelt allein die FEHLER-Zeile.
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf. DAUER: 23.77 s fuer diesen Fall gegen 148.31 s
# fuer den gruenen Vorlauf (make mutate, Zeilen "Zeit je Fall" und "Gruen-Vorlaeufe") —
# der Lauf bricht an der Traeger-Stufe ab, lange vor dem Ende von harness/tools/full-smoke.sh.
set -euo pipefail
sed -i 's/^TRAEGER_TAG ?= .*$/TRAEGER_TAG ?= v9.99.9-gibt-es-diesen-tag-nicht/' internal/emit/templates/enforce/traeger.mk
