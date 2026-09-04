#!/usr/bin/env bash
# files: internal/archive/anwenden.go
# expect: TestAnwendenTrenntMoveVonInhalt
# verify: test-go
#
# NIMMT DEM LAUF SEINEN MOVE-COMMIT: Archiv, Stubs und Verweis-Nachzug landen
# danach mit den Renames in EINEM Commit.
#
# Das ist AGENTS.md 3.3 am Gegenstand, fuer den die Regel geschrieben ist: eine
# archivierte Slice-Datei wird beim Move durch einen Stub von wenigen Zeilen
# ersetzt. Fallen Move und Ersetzung in denselben Commit, liegt die Aehnlichkeit
# unter der Rename-Schwelle, und die Herkunft der Datei ist aus dem Log nicht
# mehr ablesbar — das Einzige, was nach der Archivierung von ihr uebrig ist.
#
# Nichts davon wird von selbst rot: der Baum sieht danach genau gleich aus, das
# Zip liegt, die Stubs stehen, `make docs-check` bleibt gruen. Sichtbar ist der
# Unterschied allein in der Commit-Folge, und die liest kein Gate.
set -euo pipefail
sed -i 's|^\tif err := g.Commit("archive-welle: " + b.Welle + "  Zeitdokumente nach " + ziel + "/ (reiner Move)"); err != nil {$|\tif false {|' internal/archive/anwenden.go
