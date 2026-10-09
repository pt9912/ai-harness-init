#!/usr/bin/env bash
# files: harness/tools/kotlin-freshness.sh
# expect: kotlin-freshness: Pin ueber jedem gelieferten Kandidaten gibt kein Urteil (Exit 2)
#
# Der Pin geht wieder als Kandidat in `sort -V` ein: liegt er ueber jedem gelieferten
# Tag, wird er selbst latest, und das Urteil meldet aktuell mit einem latest-Wert, den
# keine Quelle geliefert hat. Rot werden der genannte Fall und der --latest-Fall
# "latest kommt allein aus den gelieferten Tags" in test/kotlin-freshness.bats; in den
# uebrigen Faellen ist der Pin geliefert oder niedriger als ein gelieferter Tag
# (LH-QA-02, ADR-0088).
set -euo pipefail
sed -i "s/printf '%s\\\\n' \"\\\$found\" | sort -V/printf '%s\\\\n%s\\\\n' \"\$found\" \"\$pin\" | sort -V/" harness/tools/kotlin-freshness.sh
