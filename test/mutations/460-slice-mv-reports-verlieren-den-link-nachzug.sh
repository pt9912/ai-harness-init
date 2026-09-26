#!/usr/bin/env bash
# files: harness/tools/slice-mv.sh
# expect: die vier Nicht-Link-Formen (Span, Operand, Block, Fliesstext) bleiben Byte fuer Byte
# verify: test-bats
#
# NIMMT DEM LINK-NACHZUG UNTER docs/reviews/ SEIN sed: rewrite_incoming_links_in_file
# zaehlt die Links danach weiter, ersetzt aber keinen. Die vier Nicht-Link-Formen
# bleiben stehen, der Link zeigt nach dem Wechsel auf das Verzeichnis, das die Datei
# verlassen hat, und `make docs-check` faerbt an ihm `target-missing`
# (ADR-0070, die Politik, die die Entscheidung als tote Links verwirft).
#
# WAS DAS MISST: derselbe Fall wie in 459 faerbt rot, weil er in EINER Datei den
# Link UND die vier anderen Formen fuehrt — die Haelfte, die bei der Mutation
# 459 rot wird, und die, die hier rot wird.
#
# Der Anker `psed_i -E "s@${ziel}` steht genau einmal im Skript, in
# rewrite_incoming_links_in_file
# (grep -c 'psed_i -E "s@\x24{ziel}' harness/tools/slice-mv.sh -> 1).
set -euo pipefail
sed -i '/psed_i -E "s@[$]{ziel}/d' harness/tools/slice-mv.sh
