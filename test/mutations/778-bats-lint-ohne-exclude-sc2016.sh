#!/usr/bin/env bash
# files: harness/tools/bats-lint.sh
# expect: SC2016
# verify: shell-lint
#
# ENTFERNT --exclude=SC2016 AM shellcheck-AUFRUF DES BATS-EXTRAKTS: die `$` in Einzelquotes
# der @test-Rumpfe (grep-Muster, `bash -c`-Payloads) werden gemeldet. Rot faerbt
# `make shell-lint` mit einer SC2016-Meldung `test/<name>.bats:<zeile>:<spalte>: … [SC2016]`.
# Er haelt, dass die Ausnahme am Aufruf steht; dass sie NUR dort steht (der erste Aufruf
# des Rezepts bleibt voll), faerbt kein Fall: kein Rumpf in harness/tools traegt ein `$` in
# Einzelquotes.
set -euo pipefail
sed -i "s/ --exclude=SC2016 --format=gcc/ --format=gcc/" harness/tools/bats-lint.sh
