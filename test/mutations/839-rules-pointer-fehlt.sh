#!/usr/bin/env bash
# files: internal/emit/rules.go
# expect: TestRules_PointerJeZiel
# verify: test-go
#
# NIMMT DEN POINTER WEG: die Anlage eines fehlenden Pointer-Bestandes wandert auf einen
# Pfad daneben (die Anlage schreibt unter AGENTS.md statt einer Datei ein Verzeichnis
# auf). Der Emit schreibt danach an keinem der drei exakten Namen einen Pointer mehr —
# der Waechter TestRules_PointerJeZiel faellt an der Lstat-Pruefung: der Eintraege am
# exakten Name sind kein Symlink.
#
# MR-071: das Muster trifft den Anlage-Aufruf `anlegenPointer(dst, f.ziel, rel)` an der
# realen Quelle dieses Commits.
set -euo pipefail
sed -i 's@anlegenPointer(dst, f.ziel, rel)@anlegenPointer(filepath.Join(dst, "falsch"), f.ziel, rel)@' internal/emit/rules.go
