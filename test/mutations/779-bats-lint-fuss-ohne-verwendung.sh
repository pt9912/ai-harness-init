#!/usr/bin/env bash
# files: harness/tools/bats-lint.sh
# expect: SC2034
# verify: shell-lint
#
# KUERZT DEN FUSS AUF DIE DREI ZUWEISUNGEN OHNE DEN `:`-TEIL: in jeder Datei ohne `run` sind
# `status`, `output` und `lines` zugewiesen und unbenutzt, und shellcheck meldet SC2034.
# Rot faerbt `make shell-lint` mit einer SC2034-Meldung `test/<name>.bats:<zeile>:<spalte>: …
# [SC2034]`. Der Fall haelt, dass der Fuss die Namen auch verwendet, nicht dass er sie
# deklariert (das haelt Fall 777).
set -euo pipefail
sed -i 's/^FUSS=.*$/FUSS="status=0; output=; lines=()"/' harness/tools/bats-lint.sh
