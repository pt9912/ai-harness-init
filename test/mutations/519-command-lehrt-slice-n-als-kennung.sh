#!/usr/bin/env bash
# files: internal/emit/templates/commands/implement-slice.md
# expect: TestCommands_KeinNummerierterPlatzhalter
# verify: test-go
#
# NENNT `slice-N` WIEDER ALS GUELTIGE COMMIT-KENNUNG.
#
# Die Aufzaehlung der Commit-Kennungen in implement-slice.md nennt ADR-NNNN, LH-XX-NN und
# MR-NNN; die Nummernform `slice-N` ist dort kein Teil mehr. Das Wort kehrt zurueck, ohne
# Platzhalter in spitzen Klammern — der Waechter faellt trotzdem.
set -euo pipefail
sed -i 's/`MR-NNN`; die$/`MR-NNN`, `slice-N`; die/' internal/emit/templates/commands/implement-slice.md
