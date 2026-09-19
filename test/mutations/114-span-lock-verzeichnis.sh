#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestLeftoverLockDirectoryDoesNotBlock
#
# Nimmt dem Emitter das Aufraeumen eines liegengebliebenen Lock-VERZEICHNISSES: der
# removeStaleDir-Aufruf wird durch ein os.Chmod ersetzt — das Verzeichnis wird nur
# noch in seinen Rechten angefasst, nicht entfernt. Der zweite OpenFile scheitert
# daran weiterhin mit EISDIR, und acquire kehrt mit dem Fehler zurueck — der Strom
# ist ab da dauerhaft tot. Genau das schliesst der Kommentar ueber `acquire` aus
# ("kein liegengebliebenes Schloss legt einen Strom still"). removeStaleDir nimmt
# nur ein Verzeichnis (lock_unix.go/lock_windows.go): eine Lock-DATEI an der Stelle
# wird nicht angetastet.
set -euo pipefail
sed -i 's@if rmErr := removeStaleDir(path); rmErr != nil {@if rmErr := os.Chmod(path, 0o700); rmErr != nil {@' internal/span/emit.go