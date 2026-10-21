#!/usr/bin/env bash
# files: harness/tools/bats-lint.sh
# expect: SC2154
# verify: shell-lint
#
# ERSETZT DEN FUSS DURCH EIN LEERES KOMMANDO: die Extrakte tragen die Namen `status`,
# `output` und `lines` nicht mehr als zugewiesen, und shellcheck meldet jede Verwendung
# nach einem `run` als SC2154. Rot faerbt `make shell-lint` mit einer SC2154-Meldung der
# Form `test/<name>.bats:<zeile>:<spalte>: … [SC2154]`. Er haelt, dass der Fuss die drei
# Namen deklariert, nicht dass `run` sie in jedem Fall vorher bindet.
set -euo pipefail
sed -i "s/^FUSS=.*\$/FUSS=':'/" harness/tools/bats-lint.sh
