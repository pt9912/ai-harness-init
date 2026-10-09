#!/usr/bin/env bash
# files: harness/tools/kotlin-freshness.sh
# expect: kotlin-freshness: --pinned liest DefaultKotlinVersion aus internal/gen/kotlin.go
#
# Das Skript sucht den Pin unter einem Konstanten-Namen, den internal/gen/kotlin.go
# nicht fuehrt: `--pinned` liefert leer, und der volle Lauf urteilte ueber keinen Pin.
# Rot wird allein der genannte Fall in test/kotlin-freshness.bats; die uebrigen Faelle
# reichen den Pin als Argument oder ueber KOTLIN_PINNED (LH-QA-02, ADR-0088).
set -euo pipefail
sed -i 's/const DefaultKotlinVersion = /const DefaultKotlinVer = /' harness/tools/kotlin-freshness.sh
