#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: zellenlaenge: jede Spalte der emittierten structure-Regel ist Kopfzeile
# verify: test-bats
#
# BENENNT DIE SPALTE Vertrag IM EMITTIERTEN BLOCK UM, wie es ein Baseline-Sprung an der
# Vorlage tut: test/emit-zellenlaenge-spalten.bats haelt die Spaltennamen gegen die Kopfzeilen
# der vendorten harness/README.template.md.
set -euo pipefail
sed -i 's/- name: "Vertrag"/- name: "Vertragx"/' internal/emit/templates/d-check.yml
