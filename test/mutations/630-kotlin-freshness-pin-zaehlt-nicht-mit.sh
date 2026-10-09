#!/usr/bin/env bash
# files: harness/tools/kotlin-freshness.sh
# expect: kotlin-freshness: Pin neuer als jeder gelieferte Kandidat bleibt latest
#
# Der Pin faellt aus der Kandidaten-Menge vor `sort -V`: ein Pin, der neuer ist als
# jeder gelieferte Tag, meldet dann den aelteren Kandidaten als latest und damit
# VERALTET. Rot wird allein der genannte Fall in test/kotlin-freshness.bats; in den
# uebrigen Faellen ist der Pin nie hoeher als der hoechste Kandidat (LH-QA-02, ADR-0088).
set -euo pipefail
sed -i 's/ ".pin" | sort -V/ | sort -V/' harness/tools/kotlin-freshness.sh
