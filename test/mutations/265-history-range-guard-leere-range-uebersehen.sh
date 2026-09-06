#!/usr/bin/env bash
# files: harness/tools/history-range-guard.sh
# expect: history-range-guard: leere Range (0 Commits) -> exit 1
#
# Entschaerft den Kern des Waechters: die reine Entscheidung `decide()`
# erkennt eine LEERE Range (0 Commits) nicht mehr — sie muesste jetzt genau
# EINEN Commit zaehlen, um als "leer" zu gelten. Eine tatsaechlich leere
# Range (0 Commits, der Fall aus einem flachen Klon mit einer Basis, die nur
# den einzigen vorhandenen Commit trifft) faellt danach durch den OK-Zweig —
# genau die Klasse "blind und gruen" (harness/conventions.md MR-007
# Setzung 3), gegen die dieser Waechter greift. Der Fixture-Test
# (test/history-range-guard.bats, erster Fall) deckt genau diesen Zweig.
# Match `count" -eq 0` ist SC2016-clean und in decide() eindeutig diese
# Zeile.
set -euo pipefail
sed -i 's/count" -eq 0/count" -eq 1/' harness/tools/history-range-guard.sh
