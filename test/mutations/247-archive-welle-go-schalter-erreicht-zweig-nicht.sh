#!/usr/bin/env bash
# files: cmd/ai-harness-init/archive_welle.go
# expect: TestArchiveWelleReichtDenSchalterVomArgumentBisZumZweig
# verify: test-go
#
# TRENNT DEN GEPARSTEN SCHALTER VON SEINEM ZWEIG: der Parser gewinnt den Wert
# weiter richtig, die Weitergabe an archiveWelleLauf kehrt ihn um. Ein Aufrufer
# mit `--vorschau` bekommt den schreibenden Lauf.
#
# Das ist der EINE Sprung zwischen Fall 246 (der Parser gewinnt den Wert nicht
# mehr) und Fall 242 (der Guard hat keine Wirkung mehr): dazwischen liegt die
# Weitergabe, und sie ist genau die Stelle, an der ein Test ueber dem PARAMETER
# und ein Test ueber der Parser-FUNKTION beide gruen blieben. Nur eine Messung
# ueber der ganzen Strecke — Argument-Feld rein, Baum-Abdruck raus — faellt hier.
#
# Umgekehrt statt konstant falsch, und das ist keine Kosmetik: `false` liesse
# `vorschau` ungenutzt zurueck, der Go-Uebersetzer bricht ab, und die Stufe waere
# rot ohne den erwarteten Fall — ein Gegenbeispiel, das aus dem falschen Grund
# faellt, belegt seinen Waechter nicht.
set -euo pipefail
sed -i 's/^\treturn archiveWelleLauf(root, welle, vorschau, porcelain, dateien, e\.schreibend(root), out, errOut)$/\treturn archiveWelleLauf(root, welle, !vorschau, porcelain, dateien, e.schreibend(root), out, errOut)/' \
	cmd/ai-harness-init/archive_welle.go
