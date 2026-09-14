#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: run_case meldet eine '# files:'-Angabe mit MEHR ALS EINEM Treffer mit dem Namen des Falls
# verify: test-bats
#
# ENTSCHAERFT DIE TREFFERZAHL-SCHRANKE VON resolve_file_spec: `-eq 1` wird zu
# `-ge 1`. Eine Angabe, die auf ZWEI Dateien trifft (Glob mit mehreren
# Treffern), gilt danach als aufgeloest -- resolve_file_spec liefert den
# mehrzeiligen String beider Treffer statt fehlzuschlagen. run_case reicht ihn
# ungeprueft an `tar` weiter, das ueber einem Dateinamen mit eingebettetem
# Zeilenumbruch scheitert, statt den erwarteten Befund ("... loest ... nicht
# auf genau eine Datei auf") mit dem Namen des Falls zu melden.
#
# Haelt AGENTS.md §3.6 wach: ohne diesen Zahn koennte die Zahl-Schranke in
# resolve_file_spec (LH-QA-01) unbemerkt aufweichen, und die Zusage "genau
# ein Treffer, sonst laut" waere nur im Feedforward-Quadranten.
set -euo pipefail
sed -i "s#\[ \"\$n\" -eq 1 \] || return 1#[ \"\$n\" -ge 1 ] || return 1#" harness/tools/mutate.sh
