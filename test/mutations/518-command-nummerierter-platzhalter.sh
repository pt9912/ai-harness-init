#!/usr/bin/env bash
# files: internal/emit/templates/commands/implement-slice.md
# expect: TestCommands_KeinNummerierterPlatzhalter
# verify: test-go
#
# FUEHRT DEN NUMMERIERTEN PLATZHALTER IN EINEN EMITTIERTEN COMMAND ZURUECK.
#
# `seit slice-<Kennung>` wird wieder `seit slice-<NNN>`: die Nummernform, die das Ziel als
# Kennungs-Form missverstuende, obwohl neue Slices den Namen tragen (MR-057). Die konkrete
# Dogfood-Nummern-Klasse (`slice-[0-9]{2,}`) trifft das nicht — nur der Waechter ueber den
# ganzen Command-Bestand.
set -euo pipefail
sed -i 's/seit slice-<Kennung>/seit slice-<NNN>/' internal/emit/templates/commands/implement-slice.md
