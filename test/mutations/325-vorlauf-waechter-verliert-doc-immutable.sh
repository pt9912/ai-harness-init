#!/usr/bin/env bash
# files: internal/emit/emit.go
# expect: TestDocGateMk_BindetDenVorlaufWaechter
#
# NIMMT DEM FRAGMENT DIE VORBEDINGUNG FUER `doc-immutable`.
#
# Die Bindung ist eine Zeile, und ihre Wirkung ist im gebootstrappten Ziel STILL: `make
# gates` faehrt keines der zwei history-lesenden Targets (beide brauchen eine RANGE), ein
# gruener Gate-Lauf prueft sie also nie. Ohne diese Zeile faehrt `doc-immutable` ueber einer
# aufloesbaren, aber leeren Commit-Range das Bild an; den Leerfall meldet dann erst das Modul
# `vcs` des gepinnten d-check ("Range-Leerfall", Exit 2), nicht der Waechter. Die Zeile fuer `doc-commits` bleibt stehen: der Fall misst, dass BEIDE
# Targets gebunden sind, und nicht, dass irgendwo ein Waechter haengt.
set -euo pipefail
sed -i '/^doc-immutable: history-range-guard$/d' internal/emit/emit.go
