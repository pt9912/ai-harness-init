#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestSchreibe_OhneLesbareZeileKeineFassungsZeile
#
# SCHREIBT DIE FASSUNGS-ZEILE AUCH OHNE LESBARE ZEILE. Ein leerer oder ganz unlesbarer
# Bestand — der Regelfall im frisch gebootstrappten Ziel — truege dann eine leere Zeile
# `Erfassungsregel: `, die SPEC-089 ausschliesst.
set -euo pipefail
sed -i 's/^\tif len(b.Fassungen) == 0 {$/\tif len(b.Fassungen) < 0 {/' internal/report/report.go
