#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestFeldliste_LiegtMitDemTraeger
#
# NIMMT DER TABELLEN-UEBERSCHRIFT DIE PFLICHT-SPALTE: die emittierte Feldliste traegt dann
# keine Tabelle mehr in der zugesagten Form. TestFeldliste_LiegtVerbatimImZiel faengt das
# NICHT (beide Seiten lesen dieselbe mutierte Konstante); dieser Waechter prueft den
# FESTEN Wortlaut "| Feld | Pflicht |" und faellt.
set -euo pipefail
sed -i 's/| Feld | Pflicht | Wonach gefragt wird |/| Feld | Wonach gefragt wird |/' internal/span/fieldlist.go
