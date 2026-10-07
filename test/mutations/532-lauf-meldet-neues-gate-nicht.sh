#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestRun_AddLangMeldetNeueTargets
# verify: test-go
#
# STREICHT DIE ZEILE, DIE EIN NEUES GATE AUF STDOUT NENNT.
#
# Danach schreibt der Lauf das neue Gate still in harness/mk/ai-harness-init.md; das Doku-Gate
# meldet es nicht, weil es dort deklariert ist (Kurs v6.16.0, modul-13-quality-gates.md
# §Hard Rule). Der Test haelt je neuem Gate des zweiten Moduls die Zeile mit seinem Namen.
set -euo pipefail
sed -i '/"ai-harness-init: >>> NEUES GATE: make %s/d' cmd/ai-harness-init/main.go
