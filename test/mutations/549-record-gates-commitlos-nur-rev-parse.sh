#!/usr/bin/env bash
# files: internal/emit/templates/enforce/record-gates.sh
# expect: TestStopHook_CommitBindung/ziel/HEAD_auf_fehlenden_Ref_record_rot_ohne_Stempel_Hook_Exit_2
# verify: test-go
#
# DIE COMMITLOS-ERKENNUNG VON record-gates.sh ENTFAELLT BIS AUF "rev-parse scheitert": ein
# HEAD auf einem fehlenden Ref in einem Repo mit Commits gilt als `kein-commit`, und der
# Lauf stempelt gruen statt rot (ADR-0083 Festlegung 4).
set -euo pipefail
sed -i "/^  git symbolic-ref -q HEAD >\/dev\/null || return 1\$/,/^  \[ -z \"\$alle\" \] || return 1\$/d" internal/emit/templates/enforce/record-gates.sh
