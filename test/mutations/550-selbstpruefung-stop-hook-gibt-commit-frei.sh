#!/usr/bin/env bash
# files: internal/emit/templates/enforce/stop-require-gates.sh
# expect: die Selbstpruefung im Ziel ist NICHT Exit 0
# verify: full-smoke
#
# DER EMITTIERTE STOP-HOOK HAELT EINEN NEUEN HEAD FUER DEN GESTEMPELTEN: die
# Selbstpruefung im Ziel faehrt ihn und faellt an "Commit ohne Nachweis blockiert"
# (ADR-0083 Festlegung 1, Fitness-Zeile 2). Dieselbe Mutation wie Fall 545, gemessen
# am gebootstrappten Ziel statt am tmp-Repo des Go-Tests.
set -euo pipefail
sed -i "s/if \[ \"\$current_head\" = \"\$recorded_head\" \]; then approve; fi/if [ -n \"\$current_head\" ]; then approve; fi/" internal/emit/templates/enforce/stop-require-gates.sh
