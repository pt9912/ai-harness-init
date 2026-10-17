#!/usr/bin/env bash
# files: harness/tools/digest-freshness.sh
# expect: --pins liest die fuenf realen Pin-Stellen mit Tag und Digest
#
# Das Skript sucht den golang-Digest unter einer FROM-Zeile, die das Dockerfile nicht fuehrt:
# `--pins` meldet die Stelle als nicht lesbar (Exit 2), und der Lauf gegen die Registry
# urteilte ueber keinen golang-Pin. Rot wird der Pin-Lese-Fall in test/digest-freshness.bats,
# der gegen das reale Dockerfile liest (LH-QA-02).
set -euo pipefail
sed -i 's/\^FROM golang:\[\^@ \]\*@/^FROM golang-x:[^@ ]*@/' harness/tools/digest-freshness.sh
