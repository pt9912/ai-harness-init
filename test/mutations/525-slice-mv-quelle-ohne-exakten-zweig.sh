#!/usr/bin/env bash
# files: harness/tools/slice-mv.sh
# expect: quelle: exakter Name gewinnt gegen einen laengeren Praefix-Treffer
# verify: test-bats
#
# NIMMT quelle_finden DEN EXAKTEN ZWEIG: der Pfad der ersten Schleife zeigt auf
# eine Datei, die es nie gibt, also faellt jede Angabe auf den Praefix-Zweig.
# Neben `slice-a.md` und `slice-a-b.md` trifft `SLICE=slice-a` dann `slice-a-b.md`
# statt des exakt benannten Slice.
#
# Der Anker steht genau einmal im Skript, als Pfad des exakten Zweigs
# (grep -cF 'f="$1/$d/$name.md"' harness/tools/slice-mv.sh -> 1).
set -euo pipefail
sed -i 's~f="\$1/\$d/\$name\.md"~f="$1/$d/$name.md.nie"~' harness/tools/slice-mv.sh
