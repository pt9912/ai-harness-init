#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestStripCommentHints
#
# ERSETZT DIE OFFSET-BASIERTE MASKIERUNG DURCH EINE ERSETZUNG PER FUNDSTELLEN-
# INHALT: statt der von FindAllStringIndex ermittelten Position wird die erste
# Stelle ersetzt, an der die Zeichenkette der Spanne irgendwo in der Zeile
# vorkommt.
#
# Traegt eine frueh in der Zeile stehende, zufaellig gleiche Zeichenkette (das
# Schluss-Backtick einer Spanne bildet mit dem Oeffner-Backtick der naechsten,
# unabhaengigen Spanne denselben Literal-String wie das spaeter stehende, echte
# Zitat), trifft die Ersetzung die FALSCHE, fruehere Stelle und laesst das echte
# Zitat ungeschuetzt (Review-Klasse Ersetzung-per-Literal-statt-per-Fundstelle,
# Runde 3 MEDIUM-2).
set -euo pipefail
sed -i 's/masked = masked\[:start\] + placeholder + masked\[end:\]/masked = strings.Replace(masked, span, placeholder, 1)/' internal/emit/templates.go
