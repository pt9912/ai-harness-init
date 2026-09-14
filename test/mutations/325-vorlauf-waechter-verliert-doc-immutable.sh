#!/usr/bin/env bash
# files: internal/emit/emit.go
# expect: TestDocGateMk_BindetDenVorlaufWaechter
#
# NIMMT DEM FRAGMENT DIE VORBEDINGUNG FUER `doc-immutable`.
#
# Die Bindung ist eine Zeile, und ihre Wirkung ist im gebootstrappten Ziel STILL: `make
# gates` faehrt keines der zwei history-lesenden Targets (beide brauchen eine RANGE), ein
# gruener Gate-Lauf prueft sie also nie. Ohne diese Zeile meldet `doc-immutable` ueber einer
# aufloesbaren, aber leeren Commit-Range wieder "0 Befund(e)", Exit 0 — gruen ueber leerem
# Pruefbereich. Die Zeile fuer `doc-commits` bleibt stehen: der Fall misst, dass BEIDE
# Targets gebunden sind, und nicht, dass irgendwo ein Waechter haengt.
set -euo pipefail
sed -i '/^doc-immutable: history-range-guard$/d' internal/emit/emit.go
