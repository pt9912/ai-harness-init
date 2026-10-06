#!/usr/bin/env bash
# files: harness/tools/slice-mv.sh
# expect: quelle: ein Praefix trifft nur an der Bindestrich-Grenze
# verify: test-bats
#
# WEITET DIE PRAEFIX-GRENZE ZUM TEILSTRING: quelle_finden haengt an einen Praefix
# ohne End-Bindestrich keinen `-` mehr an, der Glob trifft jeden Namen, der mit
# der Angabe beginnt. `slice-a` trifft dann `slice-ax.md`, `slice-13` zusaetzlich
# `slice-130-….md`.
#
# Der Anker steht genau einmal im Skript, als Muster-Zuweisung des Normalfalls
# (grep -cF '*) muster="$name-" ;;' harness/tools/slice-mv.sh -> 1).
set -euo pipefail
sed -i 's~\(\*) muster="[$]name\)-" ;;~\1" ;;~' harness/tools/slice-mv.sh
