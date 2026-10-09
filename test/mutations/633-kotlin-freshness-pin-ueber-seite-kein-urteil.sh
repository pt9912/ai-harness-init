#!/usr/bin/env bash
# files: harness/tools/kotlin-freshness.sh
# expect: kotlin-freshness: Pin ueber jedem gelieferten Kandidaten gibt kein Urteil (Exit 2)
#
# Der Abbruch mit Exit 2 im Urteil faellt weg: ein Pin ueber jedem gelieferten Tag geht
# an den Vergleicher und meldet VERALTET mit einem niedrigeren latest, also eine
# Herabstufung. Rot wird allein der genannte Fall in test/kotlin-freshness.bats; die
# uebrigen --judge-Faelle erreichen den Zweig nicht (LH-QA-02, ADR-0088).
set -euo pipefail
sed -i 's/^    exit 2$/    :/' harness/tools/kotlin-freshness.sh
