#!/usr/bin/env bash
# files: harness/tools/kotlin-freshness.sh
# expect: kotlin-freshness: Pin nicht geliefert, ein hoeherer Tag schon, meldet VERALTET (Exit 1)
#
# Das Urteil gibt kein Urteil schon dann, wenn latest vom Pin abweicht, statt nur, wenn
# der Pin ueber latest liegt: ein gealterter Pin, der von der nach last_updated
# sortierten Seite gefallen ist, waehrend sein Nachfolger dort steht, meldete kein
# Urteil statt VERALTET. Rot wird allein der genannte Fall in test/kotlin-freshness.bats;
# die uebrigen --judge-Faelle haben latest gleich Pin oder unter dem Pin (LH-QA-02,
# ADR-0088).
set -euo pipefail
sed -i 's/| sort -V | tail -n 1)" = "[$]pin" \]; then/| sort -V | tail -n 1)" != "" ]; then/' harness/tools/kotlin-freshness.sh
