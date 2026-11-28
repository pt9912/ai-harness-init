#!/usr/bin/env bash
# files: harness/tools/full-smoke-skip.sh
# expect: e2e-skip: deckender Stempel in der Zwei-Zeilen-Form
# verify: test-bats
#
# DER E2E-SKIP LIEST EIN FREMDES FELD (ADR-0111 Festlegung 4): die
# baum-hash-Zeile des Stempels wird in der Klassifikation nicht mehr gewaehlt —
# ein deckender Stempel taucht als fehlend/imformal auf, der Griff faellt überall
# auf den vollen Lauf zurueck, und das SKIP-Verdikt des Stempel-Laufs wird
# konservativ gar nicht mehr konserviert.
#
# Waechter ist der SKIP-Fall in test/ci-stempel-committed.bats ("e2e-skip:
# deckender Stempel in der Zwei-Zeilen-Form"): er misst die reale
# --entscheide-Klassifikation und faellt, sobald das baum-hash-Feld nicht mehr
# die Entscheidung traegt.
set -euo pipefail
sed -i 's@baum-hash" \]@baum-haxh-fremd" \]@' harness/tools/full-smoke-skip.sh
