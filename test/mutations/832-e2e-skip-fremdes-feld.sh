#!/usr/bin/env bash
# files: harness/tools/full-smoke-skip.sh
# expect: e2e-skip: alle sieben decken
# verify: test-bats
#
# DER KONSUM LIEST EIN FREMDES FELD (ADR-0113 Festlegung 1/6, a-1): die
# mengen-hash-Zeile der Stempel-Datei wird in der Klassifikation nicht mehr
# gewaehlt — der deckende Sieben-Satz ist unformal, der Griff faellt ueberall
# auf den vollen Lauf zurueck, und das SKIP-Verdikt des Stempel-Laufs wird
# konservativ gar nicht mehr konserviert.
#
# Waechter ist der SKIP-Fall in test/full-smoke-varianten-keys.bats
# ("e2e-skip: alle sieben decken -> SKIP, Meldung nennt Varianten-Menge und
# Rest (ADR-0113 Festlegung 3)"): er misst die reale --entscheide-Klassifikation
# ueber dem Fixture und faellt, sobald das mengen-hash-Feld nicht mehr die
# Entscheidung traegt.
set -euo pipefail
sed -i 's/      mengen-hash)/      baum-haxh)/' harness/tools/full-smoke-skip.sh
