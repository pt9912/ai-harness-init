#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestRun_AddLangMeldetNeueTargets
# verify: test-go
#
# STREICHT DIE ZEILE, DIE EIN NEUES TARGET OHNE GATE-ANSPRUCH AUF STDOUT NENNT.
#
# Danach steht ein neues Werkzeug-Target still in harness/mk/ai-harness-init.md; das Doku-Gate
# meldet es nicht, weil es dort deklariert ist. Der Test legt harness/mk/probe.mk mit einem
# Target ohne GATE_CHECKS ab und haelt die Zeile `neues Target: make probe-report (kein Gate)`.
set -euo pipefail
sed -i '/"ai-harness-init: neues Target: make %s (kein Gate)/d' cmd/ai-harness-init/main.go
