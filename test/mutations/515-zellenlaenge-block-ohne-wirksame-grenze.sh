#!/usr/bin/env bash
# files: internal/emit/templates/d-check.yml
# expect: FEHLER — Zellenlaenge-Gegenbeispiel (Vertrag)
# verify: full-smoke
#
# HEBT DIE GRENZE DER SPALTE Vertrag IM EMITTIERTEN BLOCK AUF 2000 ZEICHEN: der Block steht,
# das Modul ist aktiv, der gruene Start bleibt gruen — nur ein Zellsatz ueber 200 Zeichen
# faerbt docs-check im Ziel nicht mehr. Die Stufe zellenlaenge_im_ziel (full-smoke.sh) liest
# das als FEHLER: das Gegenbeispiel der Spalte Vertrag bleibt gruen.
set -euo pipefail
sed -i '/- name: "Vertrag"/{n;s/cell-max-chars: 200/cell-max-chars: 2000/}' internal/emit/templates/d-check.yml
