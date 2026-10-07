#!/usr/bin/env bash
# files: internal/emit/templates/enforce/stop-require-gates.sh
# expect: TestStopHook_CommitBindung/ziel/streng_per_Datei_ohne_neuen_HEAD_blockiert
# verify: test-go
#
# DER STOP-HOOK IGNORIERT .harness/stop-gate-streng: die versionierte Repo-Einstellung
# zum strengen Modus wirkt nicht mehr (ADR-0083 Festlegung 6).
set -euo pipefail
sed -i '/if \[ -e .harness\/stop-gate-streng \]; then streng=1; fi/d' internal/emit/templates/enforce/stop-require-gates.sh
