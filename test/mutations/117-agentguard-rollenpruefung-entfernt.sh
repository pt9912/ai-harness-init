#!/usr/bin/env bash
# files: .claude/hooks/pretooluse-agent-guard.sh
# expect: guard: general-purpose im Hintergrund -> PASS (keine Rolle)
#
# Nimmt dem Agent-Guard die ROLLEN-FRAGE: ohne die Existenzpruefung
# `.claude/agents/<name>.md` lehnt er JEDEN Agent-Aufruf ab, der nicht ausdruecklich
# im Vordergrund startet — also auch general-purpose, Explore und Plan. Das ist
# genau die Wegwerf-Sonde vom 2026-07-29, die slice-060 verworfen hat: sie belegte,
# dass PreToolUse fuer `Agent` feuert, war aber als Guard untauglich, weil sie nicht
# unterscheidet. Nicht-Rollen-Typen tragen ohnehin keine Rolle in den Span (MR-018),
# ihre Betriebsart ist frei.
#
# Rot werden in test/agent-guard.bats vier Faelle — alle vier PASS-Zusagen zu
# Nicht-Rollen (general-purpose, Explore, erfundener Typ, das Fixture-Verzeichnis
# ohne reviewer). Der Kopf nennt den ersten.
#
# Anker in DOPPELTEN Anfuehrungszeichen: der Zielausdruck traegt zwei
# Shell-Variablen, und in einfachen Anfuehrungszeichen roetet das SC2016 im
# `make shell-lint` (Lehre aus slice-034, dieselbe Bauart wie test/mutations/73).
set -euo pipefail
sed -i "s@^\[ -f \"\$agents_dir/\$stype\.md\" \] || exit 0\$@: # MUTIERT@" .claude/hooks/pretooluse-agent-guard.sh
