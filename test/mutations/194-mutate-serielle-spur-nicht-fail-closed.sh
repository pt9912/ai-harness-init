#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: ein Plan, der in ein Skript abbiegt, ist SCHWER
#
# Hebt die Fail-closed-Regel der Spur-Zuordnung auf: eine Plan-Zeile, die kein
# docker-Aufruf ist, wird danach uebersprungen statt den Modus seriell zu machen.
# `make smoke` und `make full-smoke` liefen damit nebeneinander — beide holen ihr
# Binary mit docker create/cp AUS dem Tag ai-harness-init:build, also NACH dem Bau,
# und der eine koennte das Binary des anderen extrahieren. Verschiedene Mutationen,
# ein Urteil, und zwar ein still gruenes.
set -euo pipefail
sed -i "s@= \"docker\" \] || return 1@= \"docker\" ] || continue@" harness/tools/mutate.sh
