#!/usr/bin/env bash
# files: harness/tools/kotlin-freshness.sh
# expect: kotlin-freshness: Varianten-Suffix, anderes JDK und Kurz-Tag zaehlen nicht als neuerer Tag
#
# Der Kandidaten-Filter verliert das schliessende Anfuehrungszeichen hinter dem
# JDK-Suffix: ein Varianten-Tag wie 9.9.0-jdk21-alpine zaehlt dann als 9.9.0-jdk21 und
# meldet einen neueren Tag, den es fuer den Pin nicht gibt. Rot wird allein der genannte
# Fall in test/kotlin-freshness.bats; die uebrigen Fixtures tragen keinen Varianten-Tag
# (LH-QA-02, ADR-0088).
set -euo pipefail
sed -i 's/suffix}\\"" \\/suffix}" \\/' harness/tools/kotlin-freshness.sh
