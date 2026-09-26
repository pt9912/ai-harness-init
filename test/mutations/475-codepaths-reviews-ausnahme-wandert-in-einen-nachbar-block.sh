#!/usr/bin/env bash
# files: .d-check.yml
# expect: codepaths fuehrt die Zeile exempt-paths mit docs/reviews/** — die Bedingung der Form-Regel des Nachzugs (ADR-0070)
# verify: test-bats
#
# VERSCHIEBT DIE AUSNAHME IN EINEN NACHBAR-BLOCK: die Zeile unter `codepaths:` faellt weg und
# steht wortgleich unter `vcs:`, dem naechsten Top-Level-Block. `codepaths` hat die Ausnahme
# verloren, die Form-Regel des Verweis-Nachzugs (ADR-0070) besteht weiter, und die Datei traegt die
# Zeile noch in einem Block hinter `codepaths:`.
#
# WAS DAS MISST: das Block-Ende der Block-Erkennung im Test. Endet der Block dort nicht beim
# naechsten Top-Level-Schluessel, liest er die Zeile unter `vcs:` als Zeile von `codepaths:` und
# bleibt gruen. Der Fall 474 faerbt bei ersatzlos entfernter Zeile auch ohne Block-Ende und
# bindet es darum nicht.
#
# Die Anker stehen je genau einmal in .d-check.yml: die Zeile mit zwei Zeichen Einrueckung
# (grep -c '^  exempt-paths: \["docs/reviews/\*\*"\]$' .d-check.yml -> 1) und der Schluessel
# `vcs:` in Spalte 0 (grep -c '^vcs:$' .d-check.yml -> 1).
set -euo pipefail
sed -i -e '\~^  exempt-paths: \["docs/reviews/\*\*"\]$~d' \
  -e '\~^vcs:$~a\  exempt-paths: ["docs/reviews/**"]' .d-check.yml
