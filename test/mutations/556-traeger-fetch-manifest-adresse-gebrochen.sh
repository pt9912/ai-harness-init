#!/usr/bin/env bash
# files: internal/emit/templates/enforce/traeger-fetch.sh
# expect: make traeger-fetch endet im frischen Klon mit Exit
# verify: full-smoke
#
# BRICHT DIE MANIFEST-ADRESSE IM EMITTIERTEN TRANSPORT-SKRIPT: SHA256SUMSX statt
# SHA256SUMS. Ohne Digest-Pin laedt der Fetch im frischen Klon des Ziels das Manifest
# des gepinnten Release; die Adresse gibt es dann nicht, und (b) der Stufe
# "make traeger-fetch im frischen Klon" in harness/tools/full-smoke.sh bricht. Das gilt
# nur, solange der Aufruf (klon_traeger_fetch) die Digest-Pins des Dogfood-Makefile NICHT
# erbt — erbt er sie, nimmt das Skript den Pin-Kanal, laedt das Manifest nie, und
# full-smoke bleibt gruen: der Fall bindet den Kanal des Adopters (LH-QA-02,
# ADR-0059 Festlegung 1).
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf. DAUER: 25.67 s fuer diesen Fall gegen 148.31 s
# fuer den gruenen Vorlauf (make mutate, Zeilen "Zeit je Fall" und "Gruen-Vorlaeufe") —
# der Lauf bricht an der Traeger-Stufe ab, lange vor dem Ende von harness/tools/full-smoke.sh.
set -euo pipefail
sed -i 's|/SHA256SUMS"|/SHA256SUMSX"|' internal/emit/templates/enforce/traeger-fetch.sh
