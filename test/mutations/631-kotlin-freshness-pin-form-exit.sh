#!/usr/bin/env bash
# files: harness/tools/kotlin-freshness.sh
# expect: kotlin-freshness: Pin ausserhalb der Form X.Y.Z-jdkNN bricht vor dem Fetch mit Exit 2 ab
#
# Der Abbruch bei einem Pin ausserhalb der Form X.Y.Z-jdk<NN> endet mit Exit 1
# (VERALTET) statt Exit 2 (kein Urteil). Rot wird allein der genannte Fall in
# test/kotlin-freshness.bats; `exit 2` steht im Skript nur in diesem Zweig
# (LH-QA-02, ADR-0088).
set -euo pipefail
sed -i 's/  exit 2/  exit 1/' harness/tools/kotlin-freshness.sh
