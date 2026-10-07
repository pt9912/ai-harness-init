#!/usr/bin/env bash
# files: internal/emit/templates/enforce/stop-require-gates.sh
# expect: TestStopHook_CommitBindung/ziel/unlesbarer_HEAD_Stempel_Exit_2
# verify: test-go
#
# DER FEHLERPFAD DES STOP-HOOKS ENDET MIT EXIT 0 STATT 2: ein unerwarteter Fehler liest
# sich fuer Claude Code als Freigabe (ADR-0083 Festlegung 5).
set -euo pipefail
sed -i "s/^trap 'rc=\$?; \[ \"\$rc\" -eq 0 \] || exit 2' EXIT\$/trap 'rc=\$?; [ \"\$rc\" -eq 0 ] || exit 0' EXIT/" internal/emit/templates/enforce/stop-require-gates.sh
