#!/usr/bin/env bash
# files: internal/emit/templates/enforce/stop-require-gates.sh
# expect: TestStopHook_CommitBindung/ziel/streng_per_Umgebung_1_ohne_neuen_HEAD_blockiert
# verify: test-go
#
# DER STOP-HOOK IGNORIERT STOP_GATE_STRENG: der lokale Zusatz zum strengen Modus wirkt
# nicht mehr (ADR-0083 Festlegung 6).
set -euo pipefail
sed -i "/if \\[ \"\\\${STOP_GATE_STRENG:-}\" = 1 \\]; then streng=1; fi/d" internal/emit/templates/enforce/stop-require-gates.sh
