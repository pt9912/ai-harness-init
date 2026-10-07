#!/usr/bin/env bash
# files: internal/emit/templates/enforce/stop-require-gates.sh
# expect: TestStopHook_CommitBindung/ziel/neuer_HEAD_ohne_gruenen_Lauf_blockiert
# verify: test-go
#
# DER SHA-VERGLEICH DES STOP-HOOKS GILT IMMER ALS GLEICH: ein neuer HEAD liest sich wie der
# gestempelte, und ein Commit ohne Gate-Lauf geht frei durch (ADR-0083 Festlegung 1).
set -euo pipefail
sed -i "s/if \[ \"\$current_head\" = \"\$recorded_head\" \]; then approve; fi/if [ -n \"\$current_head\" ]; then approve; fi/" internal/emit/templates/enforce/stop-require-gates.sh
