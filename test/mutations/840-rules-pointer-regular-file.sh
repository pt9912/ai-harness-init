#!/usr/bin/env bash
# files: internal/emit/rules.go
# expect: TestRules_PointerJeZiel
# verify: test-go
#
# MACHT DEN POINTER ZUM REGULAR FILE: die Anlage eines fehlenden Pointer-Bestandes
# schreibt statt des Symlinks eine Datei mit dem Zielpfad als Inhalt — die Klasse des
# Eintrags geht verloren, und der Agenten-Kontext traegt den Zielpfad als Text statt die
# Quelle zu laden. Der Waechter TestRules_PointerJeZiel faellt an der Modus-Pruefung
# (kein Symlink).
#
# MR-071: das Muster trifft die Anlage-Zeile `os.Symlink(ziel, dst)` an der realen
# Quelle dieses Commits.
set -euo pipefail
sed -i 's@os.Symlink(ziel, dst)@os.WriteFile(dst, []byte(ziel), 0o644)@' internal/emit/rules.go
