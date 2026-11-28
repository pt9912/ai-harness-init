#!/usr/bin/env bash
# files: harness/tools/full-smoke-skip.sh
# expect: e2e-skip: alle sieben decken -> SKIP, Meldung nennt Varianten-Menge und Rest (ADR-0113 Festlegung 3)
# verify: test-bats
#
# DER E2E-SKIP LIEST EIN FREMDES FELD (ADR-0111 Festlegung 4, je ADR-0113
# Festlegung 3 als je-Variante-Fassung): der case-Zweig, der das
# mengen-hash-Feld des Stempels waehlt, trift ein fremdes Muster — der
# Konsum liest kein Feld mehr, der Stempel ist unformal, die Entscheidung
# faellt auf den vollen Lauf zurueck, und das SKIP-Verdikt des Stempel-Laufs
# wird konservativ gar nicht mehr konserviert.
#
# Waechter ist der SKIP-Fall in test/full-smoke-varianten-keys.bats
# ("e2e-skip: alle sieben decken -> SKIP ..."): er misst die reale
# --entscheide-Klassifikation und faellt, sobald das mengen-hash-Feld nicht
# mehr die Entscheidung traegt.
set -euo pipefail
sed -i 's@^      mengen-hash)$@      fremd-feld)@' harness/tools/full-smoke-skip.sh
